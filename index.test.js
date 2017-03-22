const Funnel = require("./index");

describe("A basic funnel", function() {

  let count = 0;
  let funnel = {};
  let rules = {
    // in this case only one rule depends on our `input` - a reserved rule
    word(input) {
      // we emit each word in the input
      return Array.from(input.split(' ')).map((word) => this.emit(word));
    },

    // keep track of how many words have been passed into this funnel
    $word_count(self, word) {
      return this.emit(self ? self + 1 : 1);
    },

    // keep track of how many times each word has been passed in to this funnel
    $word_frequency(self, $word) {
      return this.emit(self ? self + 1 : 1);
    },

    // `char` depends on `word`, emitting charicters
    char(word) {
      return Array.from(word).map((char) => this.emit(char));
    },

    // `vowel` depends on `char` and emits a boolean
    vowel(char) {
      return this.emit(['a','e','i','o','u'].includes(char.toLowerCase()));
    },

    // `word_has_vowel` depends on `word` and `vowel`
    // it also has the special dependency `self`
    // it is keyed on `word`
    word_has_vowel(self, $word, vowel) {
      return this.emit(self || vowel);
    },

    // `word_has_vowel` depends on `input` and `word_has_vowel`
    // it is keyed on `input`
    not_english(self, $input, word_has_vowel) {
      if (self == null) { self = true; }
      return this.emit(self && word_has_vowel);
    }
  };

  beforeEach(function() {
    // Create our funnel
    funnel = new Funnel(rules);
    return count = 0;
  });
  
  describe("the basic dependency structure", () =>

    it("calls a rule each time a new set of dependencies is satisfied", function() {

      let inputString = "The quick brown fox jumps over the lazy dog";

      funnel.listen( function(input) {
        count += 1;
        return expect(input).toEqual(inputString);
      });

      funnel.listen( function(word, input) {
        count += 1;
        return expect(input.split(' ')).toContain(word);
      });

      funnel.listen( function(vowel, char) {
        count += 1;
        return expect(vowel).toEqual(['a','e','i','o','u'].includes(char.toLowerCase()));
      });

      funnel.input(inputString);
      
      return expect(count).toEqual(45);
    })
  );

  describe("keyed dependencies and the self keyword", function() {

    xit("sets self to `undefined` if rule hasn't been run with the same key", function() {
      
      funnel.listen( function(self, $input) {
        count += 1;
        return expect(self).toBeUndefined();
      });

      funnel.input('blarg');

      return expect(count).toEqual(1);
    });

    return xit("keys rules based on the `$` prefix", function() {});
  });

  return describe("persistence", function() {

    describe("non-persisted rules", function() {

      xit("initially sets `self` to `undefined` even if input is repeated", function() {
        funnel.listen( function(self, $input) {
          count += 1;
          expect(self).toBeUndefined();
          return this.emit(`Just listened to: ${$input}!`);
        });

        funnel.input('blarg');
        funnel.input('blarg');

        return expect(count).toEqual(2);
      });

      return xit("properly reduces using the `self` keyword", function() {});
    });

    return describe("persisted rules", function() {

      xit("keeps self the same if there are no keyed inputs", function() {
        funnel.listen( function(word_count) {
          count += 1;
          return expect(word_count).toEqual(count);
        });

        funnel.input('hello world!');
        funnel.input('hello world!');

        return expect(count).toEqual(2);
      });
      
      return xit("keep self the same when keyed inputs match", function() {
        funnel.listen( function(word_frequency) {
          expect(word_frequency).toEqual(parseInt(count/4)+1);
          return count += 1;
        });

        funnel.input('testing one two three');
        funnel.input('testing one two three');

        return expect(count).toEqual(2);
      });
    });
  });
});