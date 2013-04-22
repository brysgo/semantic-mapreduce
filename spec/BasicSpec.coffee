describe "A basic funnel", ->

  funnel = {}
  rules =
    # in this case only one rule depends on our `input` - a reserved rule
    word: (input) ->
      # notice how we are returning multiple times in the same function
      @return word for word in input.split(' ')

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
      @return self && word_has_vowel
  
  beforeEach ->
    # Create our funnel
    funnel = new Funnel(rules)
  
  describe "the basic dependency structure", ->

    it "calls a rule each time a new set of dependencies is satisfied", ->
      output1 = output2 = output3 = ""
      count = 0

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
