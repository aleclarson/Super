var Kind, NamedFunction, Property, Super, assert, assertType, getKind, setKind, setType, superFunc, superList, superMethod;

require("isDev");

NamedFunction = require("NamedFunction");

assertType = require("assertType");

Property = require("Property");

getKind = require("getKind");

setKind = require("setKind");

setType = require("setType");

assert = require("assert");

Kind = require("Kind");

superFunc = null;

superList = [];

superMethod = Property({
  frozen: true,
  value: function(args) {
    assert(superFunc, "No inherited method exists!");
    return superFunc.apply(this, args);
  }
});

module.exports = Super = NamedFunction("Super", function(kind, key, func) {
  var inherited, self;
  if (arguments.length < 3) {
    inherited = kind;
    func = key;
    assertType(inherited, Kind(Function));
  } else {
    assertType(kind, Kind(Function));
    assertType(key, String);
    inherited = Super.findInherited(kind, key);
    assert(inherited instanceof Function, "Cannot find inherited method for key: '" + key + "'");
  }
  assertType(func, Kind(Function));
  self = function() {
    var result;
    superList.push(superFunc);
    superFunc = inherited;
    result = func.apply(this, arguments);
    superFunc = superList.pop();
    return result;
  };
  if (isDev) {
    self.toString = function() {
      return func.toString();
    };
  }
  return setType(self, Super);
});

setKind(Super, Function);

Super.regex = /(^|\=|\:|\s|\r|\[)this.__super\(/;

Super.augment = function(type) {
  assertType(type, Kind(Function));
  if (type.prototype.__super) {
    return;
  }
  superMethod.define(type.prototype, "__super");
};

Super.findInherited = function(kind, key) {
  var inherited;
  assertType(kind, Kind(Function));
  assertType(key, String);
  inherited = null;
  while (true) {
    inherited = kind.prototype[key];
    if (inherited) {
      break;
    }
    kind = getKind(kind);
    if (!kind) {
      break;
    }
  }
  return inherited;
};

//# sourceMappingURL=map/Super.map
