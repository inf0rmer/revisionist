# ## Utility functions
#
# String Diff function
_stringDiff = require('./lib/diff')

# Extend function
extend = require('./lib/extend.coffee')

# ## The Revisionist Class
#
# The main public Class. When you create an instance of Revisionist, this is the public API you get back.
class Revisionist
  # The internal cache
  _cache = []

  # The plugin registry
  _plugins = {}

  # The version pointer
  _currentVersion = 0

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
    unless _plugins[namespace]?
      throw new Error("This plugin doesn't exist")

    _plugins[namespace] = null

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

  # The main constructor function that gets called when Revisionist is instantiated.
  constructor: (options) ->
    @options = {}
    extend @options, @defaults
    extend @options, options

  # Adds a new revision for this instance.
  change: (newValue) ->
    # Check if the plugin is available
    plugin = _plugins[@options.plugin]

    unless plugin?.change?
      throw new Error("Plugin #{@options.plugin} is not available!")

    # Call the plugin's "change" function and get it's return value for storing.
    newValue = plugin.change.call(plugin, newValue)

    # Bump the current version number
    _currentVersion += 1

    # Store the new version
    _cache.push(newValue)

    # Keep the internal cache trimmed according to the "versions" option.
    if _currentVersion > @options.versions
      # Remove the oldest version
      _cache.shift()
      # Keep the _currentVersion pointer
      _currentVersion = _cache.length

    return newValue

  # Recovers a specific revision from the cache
  recover: (version) ->
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

    if version > _cache.length
      throw new Error("This version doesn't exist")

    # Call the plugin's "recover" function and return it's return value.
    plugin.recover.call(plugin, _cache[version])

  # Represents the difference between two versions.
  diff: (v1, v2) ->
    # If no v1 is passed in, the current version is assumed
    unless v1?
      v1 = _currentVersion - 1

    # If no v2 is passed in, the current version - 1 is assumed.
    unless v2?
      v2 = _currentVersion - 2

    value1 = @recover v1
    value2 = @recover v2

    # Bail out if the type of each version does not match
    unless typeof value1 is typeof value2
      throw new Error('The content types of both versions must match')

    # Call the appropriate diff script
    type = typeof value1
    switch type
      when 'string' then _stringDiff(value2, value1)
      else throw Error("Diff algorithm unavailable for values of type #{type}")

  # Clears the cache
  clear: ->
    # Reset the internal cache
    _cache = []
    # Reset the version pointer
    _currentVersion = 0

# ## Simple Plugin
#
# This is a reference implementation for a plugin.
# It simply stores the values as they are passed in.
SimplePlugin =
  change: (newValue) ->
    return newValue

  recover: (prevValue) ->
    return prevValue

# Registers the SimplePlugin
Revisionist.registerPlugin('simple', SimplePlugin)

module.exports = Revisionist
