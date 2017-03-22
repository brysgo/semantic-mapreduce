const Funnel = require("../index");

// Create our funnel
let obj = new Funnel({
  // in this case only one rule depends on our 'input' - a reserved rule
  word(input) {
    return input.split(' ');
  },
  // 'char' depends on 'word', and splits them up into individual charicters
  char(word) {
    return (Array.from(word).map((c) => c));
  },
  // 'vowel' depends on 'char' and returns a boolean
  vowel(char) {
    return ['a','e','i','o','u'].includes(char.toLowerCase());
  },
  // 'word_has_vowel' depends on 'word' and 'vowel'
  word_has_vowel(word, vowel) {
    // notice that vowel is a list of bools now
    // this is because by the time the least common ancestor of 'word'
    // and 'vowel' ('word') run, there are multiple values for 'vowel'
    return Array.from(vowel).includes(true);
  }
});
 
// Listen to the event we are interested in
obj.listen( function(input, word_has_vowel) {
  let _not = '';
  if (Array.from(word_has_vowel).includes(false)) { _not = "not"; }
  return console.log( `The sentence '${input}' is ${_not} english!` );
});
 
// Send the input
obj.input( 'Hello I am an input string.' );
obj.input( 'Hrllw y rm rn rnprt strng.' );

debugger;