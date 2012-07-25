###
# Copyright (c) 2012 Bryan Goldstein
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ----
#
# Abstract-React is a neat little framework for mapreduce that lets you structure
# your code a bit better than most basic map and reduce functions.
###

###
Abstract-React Example
###

AR =
  # in this case only one rule depends on our 'input' - a reserved rule
  word: (input) ->
    return input.split(' ')
  # 'char' depends on 'word', and splits them up into individual charicters
  char: (word) ->
    return (c for c in word)
  # 'vowel' depends on 'char' and returns a boolean
  vowel: (char) ->
    return char.toLowerCase() in ['a','e','i','o','u']
  # 'word_has_vowel' depends on 'word' and 'vowel'
  word_has_vowel: (word, vowel) ->
    # notice that vowel is a list of bools now
    # this is because by the time the least common ancestor of 'word'
    # and 'vowel' ('word') run, there are multiple values for 'vowel'
    return true in vowel
  # even though 'input' is not used directly, it is included to change the LCA
  not_english: (input, word_has_vowel) ->
    return false in word_has_vowel

###
Abstract-React Serial Implementation
###

class AbstractReact
  
  constructor: ( @rules ) ->
    ###
    Define shortcuts for running rules.
    ###
    @lca_of_rule = {}
    for name, fn of @rules
      @[name] = ( args... ) => @run_rule( name, args )
      @lca_of_rule[name] = @lca( @arg_names( fn )... )
  
  arg_names: ( func ) ->
    ###
    Helper for getting argument names of a function.
    ###
    reg = /\(([\s\S]*?)\)/
    params = reg.exec(func)
    return params[1].split(/\s*,\s*/) if params
  
  extend: ( objects... ) ->
    ###
    Helper for extending objects.
    ###
    result = {}
    for o in objects
      for k, v of o
        result[k] ?= []
        v = [ v ] unless Object::toString.call( v ) is '[object Array]'
        result[k] = result[k].concat(v...)
    return result
  
  lca: ( rules... ) =>
    ###
    Find the lowest common ancestor of a list of rules.
    ###
    if rules.length > 2
      return @lca( @lca(rules[0...2]...), @lca(rules[2..]...) )
    else if rules.length is 1
      return rules[0]
    else
      [ one, two ] = rules
      one_ancestors = [ ]
      two_ancestors = [ ]
      one_tmp = [ one ]
      two_tmp = [ two ]
      while true
        one_ancestors = one_ancestors.concat( one_tmp )
        two_ancestors = two_ancestors.concat( two_tmp )
        for o in one_ancestors
          return o if o in two_ancestors
        one_tmp =  [].concat( (@arg_names(@rules[i]) for i in one_tmp)... )
        two_tmp =  [].concat( (@arg_names(@rules[i]) for i in two_tmp)... )
        break if undefined in one_tmp and undefined in two_tmp

  run_rule: ( rule, args ) =>
    ###
    Run a rule through our fake map-reduce implementation of AR.
    ###
    args = [ args ] unless Object::toString.call( args ) is '[object Array]'
    result = @rules[ rule ]( args... )
    console.log( "#{rule} was run with #{args} and returned #{result}." )
    return @map( rule, result )

  input: ( args... ) =>
    ###
    Run Abstract-React with the given input.
    ###
    return @map( 'input', args )
  
  reduce: ( rule, outputs ) =>
    ###
    Checks for newly fulfiled input combinations.
    ###
    for n, fn of @rules
      a = @arg_names( fn )
      args = []
      args.push( ( outputs[i] for i in a )... )
      if a.length > 1 and @lca_of_rule[ n ] is rule
        o = @run_rule( n, args )
        outputs = @extend( outputs, o )
    return outputs
  
  map: ( rule, result ) =>
    ###
    Runs all the single dependancy rules that follow from the input.
    ###
    if Object::toString.call( result ) is '[object Array]'
      return @extend( ( @map(rule, r) for r in result )... )
    else
      output = {}
      # Find and run exclusive dependants
      for n, fn of @rules
        a = @arg_names( fn )
        if a.length is 1 and @lca_of_rule[ n ] is rule
          o = @run_rule( n, result )
          o[ rule ] = result
          o = @reduce( rule, o )
          output = @extend( output, o )
      output[ rule ] ?= result
      return output
   
###
Run the AR example
###

obj = new AbstractReact(AR)
obj.input( 'Hello I am an input string.' )
obj.input( 'Hrllw y rm rn rnprt strng.')