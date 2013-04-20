describe "A basic funnel", ->

  funnel = undefined

  describe "when used to find sentences with vowels missing", ->

    beforeEach ->
      # Create our funnel
      funnel = new Funnel(
        # in this case only one rule depends on our 'input' - a reserved rule
        word: (input) ->
          @return word for word in input.split(' ')
        # 'char' depends on 'word', and splits them up into individual charicters
        # notice how we are returning multiple times in the same function
        char: (word) ->
          @return char for char in word
        # 'vowel' depends on 'char' and returns a boolean
        vowel: (char) ->
          @return char.toLowerCase() in ['a','e','i','o','u']
        ## 'word_has_vowel' depends on 'word' and 'vowel'
        #word_has_vowel: (self, word, vowel) ->
          ## notice that vowel is a list of bools now
          ## this is because by the time the least common ancestor of 'word'
          ## and 'vowel' ('word') run, there are multiple values for 'vowel'
          #@return self && vowel
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
