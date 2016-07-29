
require "isDev"

NamedFunction = require "NamedFunction"
assertType = require "assertType"
Property = require "Property"
getKind = require "getKind"
setKind = require "setKind"
setType = require "setType"
assert = require "assert"
Kind = require "Kind"

# The current "this.__super"
superFunc = null

# Support nested supers!
superList = []

# Defined on a prototype as "__super"
superMethod = Property
  frozen: yes
  value: (args) ->
    assert superFunc, "No inherited method exists!"
    superFunc.apply this, args

module.exports =
Super = NamedFunction "Super", (kind, key, func) ->

  # Was the 'inherited' function provided directly?
  if arguments.length < 3
    inherited = kind
    func = key
    assertType inherited, Kind(Function)

  else # Find the 'inherited' function by traversing the prototype chain.
    assertType kind, Kind(Function)
    assertType key, String
    inherited = Super.findInherited kind, key
    assert inherited instanceof Function, "Cannot find inherited method for key: '#{key}'"

  assertType func, Kind(Function)
  self = ->
    superList.push superFunc
    superFunc = inherited
    result = func.apply this, arguments
    superFunc = superList.pop()
    return result

  if isDev
    self.toString = ->
      func.toString()

  return setType self, Super

setKind Super, Function

Super.regex = /(^|\=|\:|\s|\r|\[)this.__super\(/

Super.augment = (type) ->
  assertType type, Kind(Function)
  return if type.prototype.__super
  superMethod.define type.prototype, "__super"
  return

Super.findInherited = (kind, key) ->
  assertType kind, Kind(Function)
  assertType key, String
  inherited = null
  loop
    inherited = kind.prototype[key]
    break if inherited
    kind = getKind kind
    break if not kind
  return inherited
