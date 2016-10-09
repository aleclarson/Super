
NamedFunction = require "NamedFunction"
assertType = require "assertType"
Property = require "Property"
getKind = require "getKind"
setKind = require "setKind"
setType = require "setType"
isDev = require "isDev"

isDev and
FunctionKind = do ->
  Kind = require "Kind"
  Kind(Function)

# The current "this.__super"
superFunc = null

# Support nested supers!
superList = []

# Defined on a prototype as "__super"
superMethod = Property
  frozen: yes
  value: (args) ->
    if isDev and not superFunc
      throw Error "Inherited method not set!"
    superFunc.apply this, args

Super = NamedFunction "Super", (kind, key, func) ->

  # Was the 'inherited' function provided directly?
  if arguments.length < 3
    inherited = kind
    func = key
    assertType inherited, FunctionKind

  else # Find the 'inherited' function by traversing the prototype chain.
    assertType kind, FunctionKind
    assertType key, String
    inherited = Super.findInherited kind, key
    if isDev and not (inherited instanceof Function)
      throw Error "Cannot find inherited method for key: '#{key}'"

  assertType func, FunctionKind
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

module.exports = setKind Super, Function

Super.augment = (type) ->
  assertType type, FunctionKind
  return if type.prototype.__super
  superMethod.define type.prototype, "__super"
  return

Super.findInherited = (kind, key) ->
  assertType kind, FunctionKind
  assertType key, String
  inherited = null
  loop
    inherited = kind.prototype[key]
    break if inherited
    kind = getKind kind
    break if not kind
  return inherited
