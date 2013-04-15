Funnel.js
---------
The goal of Funnel is to provide an elegant way to build large, scalable,
reactive apps without the need for magically scaling databases or super 
ninja skills.

This is an experimental serial implementation of Funnel.js API. Its main
purpose is to iron out a solid Funnel API before a serious implementation
begins.

## The Funnel class

Our implementation is contained in our `Funnel` class, for now this is where we
define all functions public and private that are required to make run Funnel's
event loop according to the spec.

    class Funnel

### Public API

This is the functionality that the user is expected to implement.

#### Creating a new Funnel object

The constructor is passed on object of rules. Rules are simply functions that
get automatically called with the results of other rules when all the
dependancies of the rule have been satisfied.

A rules dependancies are specified by the arguments it takes, you simply use the
name of the rule you depend on as the argument name and `Funnel` recognizes it
as a dependancy. The dependancies are considered satisfied when all of them have
been executed at least once. 

It is important to note that there is work that is done to transform the output
of a rule into the input of another.

1. Rules that were executed more than once in the time it took to satisfy the
dependancies have their results passed through as an array.
2. Rules with a single dependancy that has returned an array as its result are
called once with each of the items in the array.


      constructor: ( @rules ) ->
        @compile()

#### Listening to the results of your funnel

Listening to your funnel is the same as adding an anonymous rule. The only
difference is that you are guarenteed access to the scope where you defined your
listener function. The reason normal rules don't come with this guarentee is
that it will be much easier to scale a Funnel if we are only passing around
arguments.
        
      listen: ( fn ) =>
        key = "_#{Object.keys(@rules).length}"
        @rules.key = fn
        @compile()

#### Feeding your funnel data

Expect this to change, but right now the only way to get data into your funnel
is using the reserved input rule that passes through its arguments.
     
      input: ( args... ) =>
        return @map( 'input', args )
        
### Private Functionality

Funnel.js requires some finesse in order to properly implement the API. This is
Code you should not be calling when you use Funnel.

#### Compilation

Funnel has a very quick compilation step that must happen every time you change
the rules. This is because we have to build the dependancy tree, otherwise we
would have to do a lot more work at runtime figuring out when each rule should
be kicked off.

      compile: =>
        @lca_of_rule = {}
        for name, fn of @rules
          @[name] = ( args... ) => @run_rule( name, args )
          @lca_of_rule[name] = @lca( @arg_names( fn )... )
          
#### Argument parsing

Funnel needs to know what the names of the arguments are, normal software never
needs to do this, but since Funnel is almost a DSL it needs to do crazy stuff.

      arg_names: ( func ) ->
        reg = /\(([\s\S]*?)\)/
        params = reg.exec(func)
        return params[1].split(/\s*,\s*/) if params

#### Lowest common ancestor

This is the most mathematical part of Funnel. It recursively computes which of
its dependancies is lowest in the dependancy tree so we know which rule we come
after. This happens at compile time and can probably be optimized if need be.
      
      lca: ( rules... ) =>
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

#### Run the rule

This code runs a rule once its dependancies have been satisfied. It executes the
rule after standardizing the arguments, and it returns the result of calling map
with the rules output.
     
      run_rule: ( rule, args ) =>
        args = [ args ] unless Object::toString.call( args ) is '[object Array]'
        result = @rules[ rule ]( args... )
        return @map( rule, result )
        
#### Extend an object, much like _.extend

This is used for a couple of things, probably another thing that could get
optimized away at some point.
        
      extend: ( objects... ) ->
        result = {}
        for o in objects
          for k, v of o
            result[k] ?= []
            v = [ v ] unless Object::toString.call( v ) is '[object Array]'
            result[k] = result[k].concat(v...)
        return result

#### MAP-REDUCE!!!

The analogy here is purely self indulgent as I'm fairly certain that Funnel
could no longer be implemented as a map reduce script. However since it was
origionally intended as a framework for mapreduce, and it helps me conceptualize
the complex behavior required to carry through the execution of Funnel with all
the appropriate dependancies, I will leave it as an imperfect analogy.

The `reduce` function is responsible for handling all of the rules that have
more than one dependancy. The name is such because it turns n inputs into one
output.
      
      reduce: ( rule, outputs ) =>
        for n, fn of @rules
          a = @arg_names( fn )
          args = []
          args.push( ( outputs[i] for i in a )... )
          if a.length > 1 and @lca_of_rule[ n ] is rule
            o = @run_rule( n, args )
            outputs = @extend( outputs, o )
        return outputs

The `map` function handles all the rules with only one dependancy, thus it tends
to take a single input and turn it into many outputs. Additionally, if the input
to a rule is in the form of an array, the map function will split the array and
call the rule once with each of its items.

      map: ( rule, result ) =>
        if Object::toString.call( result ) is '[object Array]'
          return @extend( ( @map(rule, r) for r in result )... )
        else
          output = {}
          for n, fn of @rules
            a = @arg_names( fn )
            if a.length is 1 and @lca_of_rule[ n ] is rule
              o = @run_rule( n, result )
              o[ rule ] = result
              o = @reduce( rule, o )
              output = @extend( output, o )
          output[ rule ] ?= result
          return output

Export Funnel for all to use! It may be worth figuring out how to hide private
functionality.
    
    @Funnel = Funnel
    module.exports = Funnel
