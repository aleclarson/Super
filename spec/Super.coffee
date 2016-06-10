
Super = require "../src/Super"

describe "Super.augment()", ->

  it "adds '__super()' to the prototype", ->

    A = ->

    Super.augment A

    expect A::__super
      .not.toBe undefined

describe "Super()", ->

  it "wraps around a prototype method", ->

    spyA = jasmine.createSpy()
    spyB = jasmine.createSpy()

    A = ->
    A::test = spyA

    B = ->
    B::test = Super A, "test", ->
        spyB()
        @__super()

    Super.augment B

    b = new B
    b.test()

    expect spyA.calls.count()
      .toBe 1

    expect spyB.calls.count()
      .toBe 1

  it "supports nesting", ->

    spyA = jasmine.createSpy()
    spyB = jasmine.createSpy()
    spyC = jasmine.createSpy()

    A = ->
    A::test = spyA

    B = ->
    Super.augment B
    B::test = Super A::test, (a, b) ->
      spyB a, b
      @__super arguments

    C = ->
    Super.augment C
    C::test = Super B::test, (a, b) ->
      spyC a, b
      @__super arguments

    c = new C
    c.test 1, 2

    expect spyA.calls.argsFor 0
      .toEqual [ 1, 2 ]

    expect spyB.calls.argsFor 0
      .toEqual [ 1, 2 ]

    expect spyC.calls.argsFor 0
      .toEqual [ 1, 2 ]
