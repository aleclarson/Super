var Super;

Super = require("../src/Super");

describe("Super.augment()", function() {
  return it("adds '__super()' to the prototype", function() {
    var A;
    A = function() {};
    Super.augment(A);
    return expect(A.prototype.__super).not.toBe(void 0);
  });
});

describe("Super()", function() {
  it("wraps around a prototype method", function() {
    var A, B, b, spyA, spyB;
    spyA = jasmine.createSpy();
    spyB = jasmine.createSpy();
    A = function() {};
    A.prototype.test = spyA;
    B = function() {};
    B.prototype.test = Super(A, "test", function() {
      spyB();
      return this.__super();
    });
    Super.augment(B);
    b = new B;
    b.test();
    expect(spyA.calls.count()).toBe(1);
    return expect(spyB.calls.count()).toBe(1);
  });
  return it("supports nesting", function() {
    var A, B, C, c, spyA, spyB, spyC;
    spyA = jasmine.createSpy();
    spyB = jasmine.createSpy();
    spyC = jasmine.createSpy();
    A = function() {};
    A.prototype.test = spyA;
    B = function() {};
    Super.augment(B);
    B.prototype.test = Super(A.prototype.test, function(a, b) {
      spyB(a, b);
      return this.__super(arguments);
    });
    C = function() {};
    Super.augment(C);
    C.prototype.test = Super(B.prototype.test, function(a, b) {
      spyC(a, b);
      return this.__super(arguments);
    });
    c = new C;
    c.test(1, 2);
    expect(spyA.calls.argsFor(0)).toEqual([1, 2]);
    expect(spyB.calls.argsFor(0)).toEqual([1, 2]);
    return expect(spyC.calls.argsFor(0)).toEqual([1, 2]);
  });
});

//# sourceMappingURL=../../map/spec/Super.map
