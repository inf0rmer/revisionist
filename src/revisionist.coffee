# ## Utility functions
#
# HTML annotated Diff function
htmlDiff = require('./lib/diff')

# Extend function
extend = require('./lib/extend.coffee')

# ## The Revisionist Class
#
# The main public Class. When you create an instance of Revisionist, this is the public API you get back.
class Revisionist
  # The plugin registry
  _plugins = {}

  # The store registry
  _stores = {}

  # The version pointer
  _currentVersion = 0

  # The internal store
  _store = null

  # Helper function for getting the previous version of the current one.
  _getPreviousVersion = ->
    version = _currentVersion - 1

    if version < 0
      version = 0

    return version

  # This class method lets you register a new plugin.
  @registerPlugin: (namespace, Plugin) ->
    # Do not register the plugin if one with the same namespace already exists
    if _plugins[namespace]?
      throw new Error("There's already a plugin in this namespace")

    _plugins[namespace] = Plugin

  # This class method unregisters an existing plugin
  @unregisterPlugin: (namespace) ->
    _plugins[namespace] = null

  # This class method lets you register a new store
  @registerStore: (namespace, Store) ->
    # Do not register the store if one with the same namespace already exists
    if _stores[namespace]?
      throw new Error("There's already a store in this namespace")

    _stores[namespace] = Store

  # This class method unregisters an existing store
  @unregisterStore: (namespace) ->
    _stores[namespace] = null

  # The default options:
  #
  # **versions**:
  # The maximum number of versions you wish to store. The default is 10.
  #
  # **plugin**:
  # The plugin you wish to use. The default is "simple"
  #
  defaults:
    versions: 10
    plugin: 'simple'
    store: 'simple'

  # The main constructor function that gets called when Revisionist is instantiated.
  constructor: (options) ->
    # Configures options
    @options = {}
    extend @options, @defaults
    extend @options, options

    # Configure store
    @setStore(@options.store)

  # Implements a getter for _currentVersion
  getLatestVersionNumber: ->
    _currentVersion-1

  # Sets the internal store
  setStore: (store) ->
    # Bail if the chosen store is not available in the store registry
    Store = _stores[store]
    unless Store?
      throw new Error("The Store '#{store}' is not available!")

    # Construct the Store
    _store = new Store(@options)

  # Adds a new revision for this instance.
  update: (newValue) ->
    # Check if the plugin is available
    plugin = _plugins[@options.plugin]

    unless plugin?.update?
      throw new Error("Plugin #{@options.plugin} is not available!")

    # Call the plugin's "update" function and get it's return value for storing.
    newValue = plugin.update.call(plugin, newValue)

    # Bump the current version number
    _currentVersion += 1

    # Save the new version
    _store.set(newValue, _currentVersion)

    # Keep the internal cache trimmed according to the "versions" option.
    if _currentVersion > @options.versions
      # Remove the oldest version
      _store.remove(0)
      # Keep the _currentVersion pointer
      _currentVersion = _store.size()

    return newValue

  # Recovers a specific revision from the cache
  recover: (version, callback) ->
    # Check if the plugin is available
    plugin = _plugins[@options.plugin]

    unless plugin?.recover?
      throw new Error("Plugin #{@options.plugin} is not available!")

    # Defaults to the current version - 1
    unless version?
      version = _getPreviousVersion()

    # Throw errors if the version is out of bounds
    if version < 0
      throw new Error("Version needs to be a positive number")

    if version > _store.size()
      throw new Error("This version doesn't exist")

    # Call the plugin's "recover" function and return it's return value.
    # plugin.recover.call(plugin, _store.get(version))

    # Call the plugin's "recover" function and return it using the callback
    if typeof callback is 'function'
      _store.get(version, (data) ->
        # Pipe the data through from the plugin to the callback
        callback(plugin.recover.call(plugin, data))
      )

  # Represents the difference between two versions.
  diff: (v1, v2, callback) ->
    # If no v1 is passed in, the current version is assumed
    unless v1?
      v1 = _currentVersion - 1
      v1 = 0 if v1 < 0

    # If no v2 is passed in, v1 - 1 is assumed.
    unless v2?
      v2 = v1 - 1
      v2 = 0 if v2 < 0

    # Figure out which one is the old value and the new value
    min = Math.min(v1, v2)
    max = Math.max(v1, v2)

    # Returns the diff hash
    if typeof callback is 'function'
      _store.get(min, (old) ->
        _store.get(max, (n) ->
          callback {old: old, new: n}
        )
      )

  visualDiff: (v1, v2, callback) ->
    # Pipes diff() into the htmlDiff() module
    @diff(v1, v2, (diff) ->
      # Bail out if both versions are not Strings
      unless typeof diff.old is 'string' and typeof diff.new is 'string'
        throw new Error('The content types of both versions must match')

      callback( htmlDiff(diff.old, diff.new) )
    )

  # Clears the cache
  clear: ->
    # Reset the store
    _store.clear()
    # Reset the version pointer
    _currentVersion = 0

    # Chain 'this' through
    return @

# Simple Plugin, a reference implementation of a Revisionist plugin
SimplePlugin = require('./plugins/simple.coffee')

# Registers SimplePlugin
Revisionist.registerPlugin('simple', SimplePlugin)

# Simple Store, a reference implementation of a Revisionist Store
SimpleStore = require('./stores/simple.coffee')

# Registers SimpleStore
Revisionist.registerStore('simple', SimpleStore)

module.exports = Revisionist
