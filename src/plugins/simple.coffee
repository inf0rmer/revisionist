# ## Simple Plugin
#
# This is a reference implementation for a plugin.
# It simply pipes the values through the same as they are passed in.
SimplePlugin =
  update: (newValue) ->
    return newValue

  recover: (prevValue) ->
    return prevValue

module.exports = SimplePlugin
