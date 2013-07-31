define ['revisionist'], (Revisionist) ->

  describe 'Constructor', ->

    it 'defines the Revisionist class', ->
      expect(Revisionist).toBeDefined()

    it 'defaults to keeping 10 versions', ->
      rev = new Revisionist
      expect(rev.options.versions).toBe(10)

    it 'defaults to using SimplePlugin', ->
      rev = new Revisionist
      expect(rev.options.plugin).toBe('simple')

    it 'extends its options object with user-defined options', ->
      rev = new Revisionist {plugin: 'complex', versions: 20}
      expect(rev.options.versions).toBe(20)
      expect(rev.options.plugin).toBe('complex')

  describe '#change', ->

    it 'throws an Error if the plugin can\'t be found', ->
      rev = new Revisionist {plugin: 'unexistant'}
      e = new Error("Plugin unexistant is not available!")

      expect(-> rev.change('bananas')).toThrow(e)

    it 'throws an Error if the plugin doesn\'t have a "change" method', ->
      Revisionist.registerPlugin 'incomplete', {
        recover: ->
        notChange: ->
      }

      rev = new Revisionist {plugin: 'incomplete'}
      e = new Error("Plugin incomplete is not available!")

      expect(-> rev.change('bananas')).toThrow(e)

      Revisionist.unregisterPlugin 'incomplete'

    it 'calls the plugin\'s "change" method with the new value as an argument', ->
      CustomPlugin =
        recover: ->
        change: ->

      spy = spyOn CustomPlugin, 'change'

      Revisionist.registerPlugin 'custom', CustomPlugin

      rev = new Revisionist {plugin: 'custom'}
      rev.change('bacon')

      expect(spy).toHaveBeenCalledWith('bacon')

      Revisionist.unregisterPlugin 'custom'

    it 'only keeps a limited amount of versions', ->
      rev = new Revisionist {versions: 2}

      rev.change('bananas')
      rev.change('bacon')
      rev.change('pineapples')

      recovered = rev.recover(0)
      expect(recovered).toEqual('bacon')

  describe '#recover', ->

    it 'throws an Error if the plugin can\'t be found', ->
      rev = new Revisionist {plugin: 'unexistant'}
      e = new Error("Plugin unexistant is not available!")

      expect(-> rev.recover(0)).toThrow(e)

    it 'throws an Error if the plugin doesn\'t have a "change" method', ->
      Revisionist.registerPlugin 'incomplete2', {
        notRecover: ->
        change: ->
      }

      rev = new Revisionist {plugin: 'incomplete'}
      e = new Error("Plugin incomplete is not available!")

      expect(-> rev.recover(0)).toThrow(e)

    it 'throws an Error if the version is lower than 0', ->
      rev = new Revisionist
      e = new Error("Version needs to be a positive number")

      expect(-> rev.recover(-10)).toThrow(e)

    it 'throws an Error if the version doesn\'t exist yet', ->
      rev = new Revisionist
      e = new Error("This version doesn't exist")

      expect(-> rev.recover(99)).toThrow(e)

    it 'calls the plugin\'s "recover" method with the revision value as an argument', ->
      CustomPlugin =
        recover: ->
        change: ->

      spy = spyOn CustomPlugin, 'recover'

      Revisionist.registerPlugin 'custom', CustomPlugin

      rev = new Revisionist {plugin: 'custom'}
      rev.change('bacon')
      rev.recover(0)

      expect(spy).toHaveBeenCalledWith('bacon')

      Revisionist.unregisterPlugin 'custom'

    it 'defaults to the version prior to the current one', ->
      rev = new Revisionist
      rev.change('bacon')
      rev.change('bananas')
      rev.change('oranges')

      recovered = rev.recover()

      expect(recovered).toEqual('oranges')

  describe '#registerPlugin', ->

    it "exposes the registerPlugin method as a Class method", ->
      expect(Revisionist.registerPlugin).toEqual(jasmine.any(Function))



