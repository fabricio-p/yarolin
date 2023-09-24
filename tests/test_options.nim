import unittest, typetraits, sugar
import ../src/yarolin/options

suite "options":
  test "`?` macro":
    check name(?int) == "Option[system.int]"
    check name(?string) == "Option[system.string]"
  test "`or` macro":
    check (some(44) or 12) == 44
    check (none(int) or 12) == 12
  test "`<->` macro":
    check (some("foo") <-> some("bar")) == "foo"
    check (some("foo") <-> none(string)) == "foo"
    check (none(string) <-> some("bar")) == "bar"
  test "`mapIt` macro":
    block:
      let opt = some("foo").mapIt(it & " bar")
      check opt.isSome()
      check opt.get() == "foo bar"
    block:
      let opt = none(string).mapIt(cast[ptr int](int(it[0]))[])
      check not opt.isSome()
  test "`map2` function":
    block:
      let opt = map2(some(1), some(2), (a, b) => float(a + b))
      check opt.isSome()
      check typeof(opt.get()) is float
      check opt.get() == 3'f64
    block:
      let opt = map2(some(344), none(int), (a, b) => (a + b) div 0)
      check not opt.isSome()
  test "`map2AB` macro":
    block:
      let opt = map2AB(some(1), some(2)):
        float(a + b)
      check opt.isSome()
      check typeof(opt.get()) is float
      check opt.get() == 3'f64
    block:
      let opt = map2AB(some(344), none(int)):
        (a + b) div 0
      check not opt.isSome()
