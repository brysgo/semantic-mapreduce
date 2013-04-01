Funnel = require("../src/funnel")

# Create our funnel
obj = new Funnel(
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
)
 
# Listen to the event we are interested in
obj.listen( (input, word_has_vowel) ->
  _not = ''
  _not = "not" if false in word_has_vowel
  console.log( "The sentence '#{input}' is #{_not} english!" )
)
 
# Send the input
obj.input( 'Hello I am an input string.' )
obj.input( 'Hrllw y rm rn rnprt strng.' )