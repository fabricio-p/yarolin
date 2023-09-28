import unittest, typetraits, sugar, strutils
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
  test "`try` macro":
    func foo(yes: bool): Option[string] =
      if yes: some("foo")
      else: none(string)
    func bar(yes: bool): Option[string] =
      let value = foo(yes).try
      result = some(value & " bar")
    block:
      let opt = bar(true)
      check opt.isSome()
      check opt.get() == "foo bar"
    block:
      let opt = bar(false)
      check opt.isSome() == false
  test "`orReturn` macro":
    func foo(yes: bool): Option[string] =
      if yes: some("400")
      else: none(string)
    func bar(yes: bool): int =
      let value = foo(yes).orReturn 10
      result = value.parseInt()
    check bar(true) == 400
    check bar(false) == 10
  test "`isSomeAnd` function":
    check some(33).isSomeAnd(x => x mod 3 == 0)
    check some(20).isSomeAnd(x => x mod 3 == 0) == false
    check none(int).isSomeAnd(_ => true) == false
  test "`isSomeAndIt` macro":
    check some(33).isSomeAndIt(it mod 3 == 0)
    check some(20).isSomeAndIt(it mod 3 == 0) == false
    check none(int).isSomeAndIt(true) == false
