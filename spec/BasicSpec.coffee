describe "A basic funnel", ->

  count = 0
  funnel = {}
  rules =
    # in this case only one rule depends on our `input` - a reserved rule
    word: (input) ->
      # notice how we are returning multiple times in the same function
      @return word for word in input.split(' ')

    # keep track of how many words have been passed into this funnel
    $word_count: (self, word) ->
      @return if self then self + 1 else 1

    # keep track of how many times each word has been passed in to this funnel
    $word_frequency: (self, $word) ->
      @return if self then self + 1 else 1

    # `char` depends on `word`, returning charicters
    char: (word) ->
      @return char for char in word

    # `vowel` depends on `char` and returns a boolean
    vowel: (char) ->
      @return char.toLowerCase() in ['a','e','i','o','u']

    # `word_has_vowel` depends on `word` and `vowel`
    # it also has the special dependency `self`
    # it is keyed on `word`
    word_has_vowel: (self, $word, vowel) ->
      @return self || vowel

    # `word_has_vowel` depends on `input` and `word_has_vowel`
    # it is keyed on `input`
    not_english: (self, $input, word_has_vowel) ->
      self ?= true
      @return self && word_has_vowel

  beforeEach ->
    # Create our funnel
    funnel = new Funnel(rules)
    count = 0
  
  describe "the basic dependency structure", ->

    it "calls a rule each time a new set of dependencies is satisfied", ->

      inputString = "The quick brown fox jumps over the lazy dog"

      funnel.listen( (input) ->
        count += 1
        expect(input).toEqual inputString
      )

      funnel.listen( (word, input) ->
        count += 1
        expect(input.split(' ')).toContain word
      )

      funnel.listen( (vowel, char) ->
        count += 1
        expect(vowel).toEqual char.toLowerCase() in ['a','e','i','o','u']
      )

      funnel.input(inputString)
      
      expect(count).toEqual 45

  describe "keyed dependencies and the self keyword", ->

    xit "sets self to `undefined` if rule hasn't been run with the same key", ->
      
      funnel.listen( (self, $input) ->
        count += 1
        expect(self).toBeUndefined()
      )

      funnel.input('blarg')

      expect(count).toEqual 1

    xit "keys rules based on the `$` prefix", ->

  describe "persistence", ->

    describe "non-persisted rules", ->

      xit "initially sets `self` to `undefined` even if input is repeated", ->
        funnel.listen( (self, $input) ->
          count += 1
          expect(self).toBeUndefined()
          @return "Just listened to: #{$input}!"
        )

        funnel.input('blarg')
        funnel.input('blarg')

        expect(count).toEqual 2

      xit "properly reduces using the `self` keyword", ->

    describe "persisted rules", ->

      xit "keeps self the same if there are no keyed inputs", ->
        funnel.listen( (word_count) ->
          count += 1
          expect(word_count).toEqual count
        )

        funnel.input('hello world!')
        funnel.input('hello world!')

        expect(count).toEqual 2
      
      xit "keep self the same when keyed inputs match", ->
        funnel.listen( (word_frequency) ->
          expect(word_frequency).toEqual parseInt(count/4)+1
          count += 1
        )

        funnel.input('testing one two three')
        funnel.input('testing one two three')

        expect(count).toEqual 2
