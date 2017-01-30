
# Super v1.1.0 ![stable](https://img.shields.io/badge/stability-stable-4EBA0F.svg?style=flat)

```coffee
Super = require "Super"

Foo = ->
  # Add properties here.

Foo::test = ->
  console.log "Foo::test()"

Bar = ->
  # Add properties here.

Bar::test = Super Foo, "test", ->
  console.log "Bar::test()"
  @__super arguments

Super.augment Bar

bar = new Bar
bar.test() # Prints "Bar::test()" then "Foo::test()"
```

- Nested `this.__super` calls are supported!

- You can pass the inherited function directly, if desired!

```coffee
Bar::test = Super Foo::test, ->
  @__super arguments
```
