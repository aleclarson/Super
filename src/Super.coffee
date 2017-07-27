
NamedFunction = require "NamedFunction"
assertType = require "assertType"
Property = require "Property"
getKind = require "getKind"
isDev = require "isDev"

if isDev
  Kind = require "Kind"
  Function.Kind ?= Kind Function

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
    assertType inherited, Function.Kind

  else # Find the 'inherited' function by traversing the prototype chain.
    assertType kind, Function.Kind
    assertType key, String
    inherited = Super.findInherited kind, key
    if isDev and not (inherited instanceof Function)
      throw Error "Cannot find inherited method for key: '#{key}'"

  assertType func, Function.Kind
  self = ->
    superList.push superFunc
    superFunc = inherited
    result = func.apply this, arguments
    superFunc = superList.pop()
    return result

  if isDev
    self.toString = ->
      func.toString()

  return self

module.exports = Super

Super.augment = (type) ->
  assertType type, Function.Kind
  return if type.prototype.__super
  superMethod.define type.prototype, "__super"
  return

Super.findInherited = (kind, key) ->
  assertType kind, Function.Kind
  assertType key, String

  inherited = null
  loop
    inherited = kind.prototype[key]
    break if inherited

    kind = getKind kind
    break if not kind

  return inherited
