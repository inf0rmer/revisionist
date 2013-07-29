# # Revisionist
#
# Revisionist is a simple tool to help you manage versions of content in your web application.
# Everytime your data changes, you can save it as a revision in a Revisionist instance.
# You can then access the last x versions of your content (10 by default).
#
# ## Plugin Architecture
#
# Revisionist uses a plugin architecture, so you can override the default behavior of it's two main functions.
# The "Simple" plugin shipped by default simply stores and returns the values as they're passed in.

# Simple extend function
extend = (target={}, other) ->
  for prop of other
    if typeof source[prop] is 'object'
      target[prop] = extend(target[prop], source[prop])
    else
      target[prop] = source[prop]

  return target

# ## The Revisionist Class
#
# The main public Class. When you create an instance of Revisionist, this is the public API you get back.
class Revisionist
  # The internal cache
  _cache = []

  # The plugin registry
  _plugins = {}

  # This class method lets you register a new plugin.
  @register: (namespace, Plugin) ->
    # Do not register the plugin if one with the same namespace
    # already exists
    if _plugins[namespace]?
      throw new Error("There's already a plugin in this namespace!")

    _plugins[namespace] = Plugin

  # The default options:
  #
  # **versions**:
  # The maximum number of versions you wish to store. The default is 10.
  #
  # **plugin**:
  # The plugin you wish to use. The default is "simple"
  #
  options:
    versions: 10
    plugin: 'simple'

  # The main constructor function that gets called when Revisionist is instantiated.
  constructor: (options) ->
    @options = extend @options, options
    @_currentVersion = 0

  # Adds a new revision for this instance.
  change: (newValue) ->
    # Call the plugin's "change" function and get it's return value for storing.
    newValue = _plugin.change.call(@, @_currentVersion)

    # Bump the current version number
    @_currentVersion += 1

    # Store the new version
    _cache.push(newValue)

    # Keep the internal cache trimmed according to the "versions" option.
    if @_currentVersion > @options.versions
      _cache.shift()

    return newValue

  # Recovers a specific revision from the cache
  recover: (version) ->
    # Defaults to the current version - 1
    unless version?
      version -= 1

    # Throw errors if the version is out of bounds
    if version < 0
      throw new Error("Version needs to be a positive number")

    if version > _cache.length
      throw new Error("Not enough versions yet")

    # Call the plugin's "recover" function and return it's return value.
    _plugin.recover.call(@, _cache[version])

  # Clears the cache
  clear: ->
    _cache = []

# ### Simple Plugin
#
# This is a reference implementation for a plugin.
# It simply stores the values as they are passed in.
SimplePlugin =
  change: (newValue) ->
    return newValue

  recover: (prevValue) ->
    return prevValue

# Register the SimplePlugin
Revisionist.register('simple', SimplePlugin)
