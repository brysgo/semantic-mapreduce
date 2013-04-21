describe "A basic funnel", ->

  funnel = undefined

  describe "when used to find sentences with vowels missing", ->

    beforeEach ->
      # Create our funnel
      funnel = new Funnel(
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

      )

    it "should call `word` with every string sent to `input`", ->
      inputString = "here we go!"
      outputString = ""
      funnel.listen( (input) -> outputString += input )
      funnel.input(inputString)
      expect(outputString).toEqual inputString
      
    it "should call char once with every array item returned by word", ->
      inputString = "here we go again"
      outputString = ""
      funnel.listen( (word) -> outputString += word )
      funnel.word(inputString)
      expect(outputString).toEqual inputString.replace(/\ /g,'')

    it "should call vowel with every boolean returned by char", ->
      inputString = "iw"
      outputString = ""
      funnel.listen( (vowel) -> outputString += vowel )
      funnel.char(inputString)
      expect(outputString).toEqual "truefalse"
