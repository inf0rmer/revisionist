define ['revisionist'], (Revisionist) ->

  describe 'Constructor', ->

    rev = null
    afterEach ->
      rev?.clear()
      rev = null

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
    rev = null
    afterEach ->
      rev?.clear()
      rev = null

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

    it 'calls the store\'s "set" method with the new value and the new revision number as arguments', ->
      class CustomStore
        set: (value, version) ->

        clear: ->

      Revisionist.registerStore 'custom', CustomStore

      rev = new Revisionist {store: 'custom'}
      spy = spyOn CustomStore.prototype, 'set'

      rev.change 'bacon'

      expect(spy).toHaveBeenCalledWith('bacon', 1)

      Revisionist.unregisterStore 'custom'

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

    it 'calls the plugin\'s "change" method within it\'s own context', ->
      CustomPlugin =
        recover: ->
        change: ->
          @ownFunction()
        ownFunction: ->

      spy = spyOn CustomPlugin, 'ownFunction'

      Revisionist.registerPlugin 'custom', CustomPlugin

      rev = new Revisionist {plugin: 'custom'}
      rev.change('pancakes')

      expect(spy).toHaveBeenCalled()

      Revisionist.unregisterPlugin 'custom'

    it 'only keeps a limited amount of versions', ->
      rev = new Revisionist {versions: 2}

      rev.change('bananas')
      rev.change('bacon')
      rev.change('pineapples')

      recovered = rev.recover(0)
      expect(recovered).toEqual('bacon')

  describe '#recover', ->
    rev = null
    afterEach ->
      rev?.clear()
      rev = null

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

    it 'calls the store\'s "get" method with the revision number as an argument', ->
      class CustomStore
        get: (version) ->
          "bacon"

        size: ->
          1

        clear: ->

      Revisionist.registerStore 'custom', CustomStore

      rev = new Revisionist {store: 'custom'}

      expect( do rev.recover).toEqual('bacon')

      Revisionist.unregisterStore 'custom'

    it 'calls the plugin\'s "recover" method with the revision value as an argument', ->
      CustomPlugin =
        recover: ->
        change: (value)->
          value

      spy = spyOn CustomPlugin, 'recover'

      Revisionist.registerPlugin 'custom', CustomPlugin

      rev = new Revisionist {plugin: 'custom'}
      rev.change('bacon')
      rev.recover(0)

      expect(spy).toHaveBeenCalledWith('bacon')

      Revisionist.unregisterPlugin 'custom'

    it 'calls the plugin\'s "recover" method within it\'s own context', ->
      CustomPlugin =
        recover: ->
          @ownFunction()
        change: ->
        ownFunction: ->

      spy = spyOn CustomPlugin, 'ownFunction'

      Revisionist.registerPlugin 'custom', CustomPlugin

      rev = new Revisionist {plugin: 'custom'}
      rev.change('pancakes')
      rev.recover()

      expect(spy).toHaveBeenCalled()

      Revisionist.unregisterPlugin 'custom'

    it 'defaults to the version prior to the current one', ->
      rev = new Revisionist
      rev.change('bacon')
      rev.change('bananas')
      rev.change('oranges')

      recovered = rev.recover()

      expect(recovered).toEqual('oranges')

  describe '#diff', ->
    rev = null

    beforeEach ->
      rev = new Revisionist

    afterEach ->
      rev.clear()
      rev = null

    it 'returns a diff hash with old and new keys', ->
      rev.change 1
      rev.change 3
      rev.change 10

      diff = rev.diff(0, 2)
      expect(diff.old).toEqual(1)
      expect(diff.new).toEqual(10)

    it 'compares the two most recent versions if no parameters are passed in', ->
      rev.change 1
      rev.change 3
      rev.change 10

      diff = rev.diff()

      expect(diff.old).toEqual(3)
      expect(diff.new).toEqual(10)

    it 'compares the passed in version against the version before it if only one parameter is passed in', ->
      rev.change 1
      rev.change 3
      rev.change 10

      diff = rev.diff(1)

      expect(diff.old).toEqual(1)
      expect(diff.new).toEqual(3)

  describe '#visualDiff', ->

    rev = null

    beforeEach ->
      rev = new Revisionist

    afterEach ->
      rev.clear()
      rev = null

    it 'throws an Error if the content types are not both String', ->
      rev.change 'string'
      rev.change 2

      e = new Error('The content types of both versions must match')

      expect( -> rev.visualDiff()).toThrow(e)

    it 'returns an HTML annotated diff for String values', ->
      rev.change 'fox'
      rev.change 'the brown fox jumped over the lazy wizard'
      expectedDiff = '<ins>the </ins><ins>brown </ins> fox <ins>jumped </ins><ins>over </ins><ins>the </ins><ins>lazy </ins><ins>wizard\n</ins>'

      diff = rev.visualDiff()
      expect(diff).toEqual(expectedDiff)

  describe '#getLatestVersionNumber', ->
    rev = null
    afterEach ->
      rev?.clear()
      rev = null

    it "exposes the latest version number", ->
      rev = new Revisionist
      rev.change(1)
      rev.change(2)
      rev.change(3)

      latest = rev.getLatestVersionNumber()

      expect(latest).toEqual(2)

  describe '#setStore', ->

    it 'throws an Error if an non-existing store is set', ->
      rev = new Revisionist
      e = new Error("The Store 'bogus' is not available!")

      expect(-> rev.setStore('bogus')).toThrow(e)

    it 'calls the Store constructor with the Revisionist options hash as an argument', ->
      opts = null
      done = false

      class CustomStore
        constructor: (options) ->
          opts = options
          done = true

      Revisionist.registerStore 'custom', CustomStore

      rev = new Revisionist
      rev.setStore('custom')
      expect(done).toBeTruthy()
      expect(opts).toEqual(rev.options)

      Revisionist.unregisterStore 'custom', CustomStore

  describe '.registerPlugin', ->
    it "exposes the registerPlugin method as a Class method", ->
      expect(Revisionist.registerPlugin).toEqual(jasmine.any(Function))

  describe '.registerStore', ->
    it "exposes the registerStore method as a Class method", ->
      expect(Revisionist.registerStore).toEqual(jasmine.any(Function))

    it "throws an Error if a namespace is already taken", ->
      e = new Error("There's already a store in this namespace")
      expect(-> Revisionist.registerStore('simple')).toThrow(e)

  describe '.unregisterStore', ->
    it "exposes the unregisterStore method as a Class method", ->
      expect(Revisionist.unregisterStore).toEqual(jasmine.any(Function))

