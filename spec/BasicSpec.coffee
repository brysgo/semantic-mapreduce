describe "A basic funnel", ->

  funnel = undefined

  describe "when used to find sentences with vowels missing", ->

    beforeEach ->
      # Create our funnel
      funnel = new Funnel(
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

    it "should call `word` with every string sent to `input`", ->
      inputString = "here we go!"
      outputString = ""
      funnel.listen( (word) -> outputString += word )
      funnel.input(inputString)
      expect(outputString).toEqual inputString
      
    it "should call char once with every array item returned by word", ->
      # TODO: decouple tests from preceding ones
      inputString = "here we go again"
      outputString = ""
      funnel.listen( (char) -> outputString += char )
      funnel.input(inputString)
      expect(outputString).toEqual inputString.replace(/\ /g,'')

    it "should call vowel with every boolean returned by char", ->
      # TODO: decouple tests from preceding ones
      inputString = "iw"
      outputString = ""
      funnel.listen( (vowel) -> outputString += vowel )
      funnel.input(inputString)
      expect(outputString).toEqual "truefalse"

    it "should call word_has_vowel once for every word, with vowels down the tree from the word collected", ->
    it "should call our listener with a boolean for every word", ->
