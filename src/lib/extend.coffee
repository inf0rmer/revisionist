# Simple extend function
extend = (target={}, source) ->
  for prop of source
    if typeof source[prop] is 'object'
      target[prop] = extend(target[prop], source[prop])
    else
      target[prop] = source[prop]

  return target

module.exports = extend
