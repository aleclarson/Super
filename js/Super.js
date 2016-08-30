var FunctionKind, NamedFunction, Property, Super, assertType, getKind, setKind, setType, superFunc, superList, superMethod;

require("isDev");

NamedFunction = require("NamedFunction");

assertType = require("assertType");

Property = require("Property");

getKind = require("getKind");

setKind = require("setKind");

setType = require("setType");

isDev && (FunctionKind = (function() {
  var Kind;
  Kind = require("Kind");
  return Kind(Function);
})());

superFunc = null;

superList = [];

superMethod = Property({
  frozen: true,
  value: function(args) {
    if (isDev && !superFunc) {
      throw Error("Inherited method not set!");
    }
    return superFunc.apply(this, args);
  }
});

Super = NamedFunction("Super", function(kind, key, func) {
  var inherited, self;
  if (arguments.length < 3) {
    inherited = kind;
    func = key;
    assertType(inherited, FunctionKind);
  } else {
    assertType(kind, FunctionKind);
    assertType(key, String);
    inherited = Super.findInherited(kind, key);
    if (isDev && !(inherited instanceof Function)) {
      throw Error("Cannot find inherited method for key: '" + key + "'");
    }
  }
  assertType(func, FunctionKind);
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

module.exports = setKind(Super, Function);

Super.regex = /(^|\=|\:|\s|\r|\[)this.__super\(/;

Super.augment = function(type) {
  assertType(type, FunctionKind);
  if (type.prototype.__super) {
    return;
  }
  superMethod.define(type.prototype, "__super");
};

Super.findInherited = function(kind, key) {
  var inherited;
  assertType(kind, FunctionKind);
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
