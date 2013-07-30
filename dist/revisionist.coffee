((global) ->
  # ## Utility functions
  #
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
  
    # The version pointer
    _currentVersion = 0
  
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
  
    # Adds a new revision for this instance.
    change: (newValue) ->
      # Check if the plugin is available
      plugin = _plugins[@options.plugin]
  
      unless plugin?.change?
        throw new Error("Plugin #{@options.plugin} is not available!")
  
      # Call the plugin's "change" function and get it's return value for storing.
      newValue = plugin.change.call(@, newValue)
  
      # Bump the current version number
      _currentVersion += 1
  
      # Store the new version
      _cache.push(newValue)
  
      # Keep the internal cache trimmed according to the "versions" option.
      if _currentVersion > @options.versions
        _cache.shift()
  
      return newValue
  
    # Recovers a specific revision from the cache
    recover: (version) ->
      # Check if the plugin is available
      plugin = _plugins[@options.plugin]
  
      unless plugin?.recover?
        throw new Error("Plugin #{@options.plugin} is not available!")
  
      # Defaults to the current version - 1
      unless version?
        version = _currentVersion - 1
  
      # Throw errors if the version is out of bounds
      if version < 0
        throw new Error("Version needs to be a positive number")
  
      if version > _cache.length
        throw new Error("Not enough versions yet")
  
      # Call the plugin's "recover" function and return it's return value.
      plugin.recover.call(@, _cache[version])
  
    # Clears the cache
    clear: ->
      _cache = []
  
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
  Revisionist.register('simple', SimplePlugin)

  if typeof define is 'function' and define.amd? #AMD
    define( -> return Revisionist)
  else if typeof module isnt undefined and module.exports? #node
    module.exports = Revisionist
  else #browser
    # Use string because of Google closure compiler ADVANCED_MODE
    # jslint sub:true
    global['Revisionist'] = Revisionist

)(this)