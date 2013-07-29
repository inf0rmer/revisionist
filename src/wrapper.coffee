((global) ->
  #= ./revisionist.coffee

  if typeof define is 'function' and define.amd? #AMD
    define( -> return Revisionist)
  else if typeof module isnt undefined and module.exports? #node
    module.exports = Revisionist
  else #browser
    # Use string because of Google closure compiler ADVANCED_MODE
    # jslint sub:true
    global['Revisionist'] = Revisionist

)(this)
