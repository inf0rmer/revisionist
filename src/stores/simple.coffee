class SimpleStore
  _cache = []

  initialize: (@options) ->

  set: (value, version) ->
    _cache.push(value)

  get: (version) ->
    _cache[version]

  remove: (version) ->
    _cache.splice(version, 1)

  clear: ->
    _cache = []

  size: ->
    _cache.length

module.exports = SimpleStore
