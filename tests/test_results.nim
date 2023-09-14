import unittest, typetraits, sugar
import ../src/yarolin/results

suite "results":
  test "`!` macro":
    check name(int!int) == "Result[system.int, system.int]"
    check name(int!void) == "Result[system.void, system.int]"
  test "successful function":
    check successful(success[int, void](12))
    check not successful(failure[void, string]("boo"))
  test "unsafeGetVal function":
    let res = success[int, void](10)
    check unsafeGetVal(res) != nil
    check name(typeof(unsafeGetVal(res))) == "ptr int"
    check unsafeGetVal(res)[] == 10
  test "unsafeGetErr function":
    let res = failure[void, int](420)
    check unsafeGetErr(res) != nil
    check name(typeof(unsafeGetErr(res))) == "ptr int"
    check unsafeGetErr(res)[] == 420
  test "getVal function":
    block:
      let res = success[int, void](1244)
      var raised = false
      try:
        check getVal(res) == 1244
      except UnpackValDefect:
        raised = true
      check raised == false
    block:
      let res = failure[void, int](765456)
      var raised = false
      try:
        getVal(res)
      except UnpackValDefect:
        raised = true
      check raised == true
  test "getErr function":
    block:
      let res = failure[void, int](765456)
      var raised = false
      try:
        check getErr(res) == 765456
      except UnpackValDefect:
        raised = true
      check raised == false
    block:
      let res = success[int, void](1244)
      var raised = false
      try:
        getErr(res)
      except UnpackErrDefect:
        raised = true
      check raised == true
  test "`!+` macro":
    let res = int!int !+ 69
    check successful(res)
    check res.getVal() == 69
  test "`!-` macro":
    let res = int!int !- -1
    check not successful(res)
    check res.getErr() == -1
  test "`=!+` macro":
    var res: int!int
    res =!+ 69
    check successful(res)
    check res.getVal() == 69
  test "`=!-` macro":
    var res: int!int
    res =!- -1
    check not successful(res)
    check res.getErr() == -1
  test "`or` macro":
    let
      res1 = success[int, int](122)
      res2 = failure[int, int](1231)
    check (res1 or 99) == 122
    check (res2 or 0xdead) == 0xdead
  test "`try` macro":
    proc foo(fail: bool): string!int =
      if fail:
        return failure[int, string]("frfr")
      else:
        return success[int, string](0xdeadbeef)
    proc bar(fail: bool): string!string =
      discard foo(fail).try
      return success[string, string]("yas")
    check bar(false).successful()
    check not bar(true).successful()
  test "`throw` function":
    block:
      var raised = false
      try:
        discard success[string, string]("bumblebee, pass me the autobud")
                .throw()
      except CatchableError:
        raised = true
      check raised == false
    block:
      var raised = false
      try:
        discard failure[string, string](
          "yo optimus, check out this energon bland")
          .throw()
      except CatchableError:
        raised = true
      check raised == true
  test "`throw` function with custom exception":
    type Death = object of CatchableError
    block:
      var died = false
      try:
        discard success[string, string]("loud loud zaza").throw(Death)
      except Death:
        died = true
      check died == false
    block:
      var died = false
      try:
        discard failure[string, string]("it is black corn").throw(Death)
      except Death:
        died = true
      check died == true
  test "`successfulAnd` function":
    block:
      let res = success[int, string](0xabc)
      check res.successfulAnd(val => val == 0xabc)
    block:
      let res = failure[int, string]("💀") # <C-V>U1f480 to get it in vim
      check res.successfulAnd(val => val == 0xabc) == false
  test "`unsuccessfulAnd` function":
    block:
      let res = failure[int, string]("💀")
      check res.unsuccessfulAnd(err => err.len == 4)
    block:
      let res = success[int, string](0xabc)
      check res.unsuccessfulAnd(err => err.len == 4) == false
  test "`successfulAndIt` macro":
    block:
      let res = success[int, string](0xabc)
      check res.successfulAndIt(it == 0xabc)
    block:
      let res = failure[int, string]("💀") # <C-V>U1f480 to get it in vim
      check res.successfulAndIt(it == 0xabc) == false
  test "`unsuccessfulAndIt` macro":
    block:
      let res = failure[int, string]("💀")
      check res.unsuccessfulAndIt(it.len == 4)
    block:
      let res = success[int, string](0xabc)
      check res.unsuccessfulAndIt(it.len == 4) == false
  test "`mapVal` function":
    block:
      let res = success[int, string](15).mapVal(val => val + 54)
      check res.successful()
      check res.unsafeGetVal()[] == 69
    block:
      let res = failure[int, string]("unalive").mapVal(val => val + val)
      check res.unsuccessful()
      check res.unsafeGetErr()[] == "unalive"
  test "`mapValOr` function":
    block:
      let val = success[int, string](44).mapValOr(22, val => val - 4)
      check val == 40
    block:
      let val = failure[int, string]("").mapValOr(22, val => val - 4)
      check val == 22
  test "`mapValOrElse` function":
    block:
      let val =
        success[int, string](121)
          .mapValOrElse(err => int(err[0]), val => val + 299)
      check val == 420
    block:
      let val =
        failure[int, string]("F")
          .mapValOrElse(err => ord(err[0]), val => -val)
      check val == ord('F')
  test "`mapErr` function":
    block:
      let res = failure[int, string]("foo").mapErr(err => err & " bar")
      check res.unsuccessful()
      check res.getErr() == "foo bar"
    block:
      let res = success[int, string](55).mapErr(err => err & " bar")
      check res.successful()
      check res.getVal() == 55
  test "`mapValIt` macro":
    block:
      let res = success[int, string](15).mapValIt(it + 54)
      check res.successful()
      check res.unsafeGetVal()[] == 69
    block:
      let res = failure[int, string]("unalive").mapValIt(it + it)
      check res.unsuccessful()
      check res.unsafeGetErr()[] == "unalive"
  test "`mapValOrIt` macro":
    block:
      let val = success[int, string](44).mapValOrIt(22, it - 4)
      check val == 40
    block:
      let val = failure[int, string]("").mapValOrIt(22, it - 4)
      check val == 22
  test "`mapValOrElse` function":
    block:
      let val = success[int, string](121).mapValOrElseIt(int(it[0]), it + 299)
      check val == 420
    block:
      let val = failure[int, string]("F").mapValOrElseIt(ord(it[0]), -it)
      check val == ord('F')
  test "`mapErrIt` macro":
    block:
      let res = failure[int, string]("foo").mapErrIt(it & " bar")
      check res.unsuccessful()
      check res.getErr() == "foo bar"
    block:
      let res = success[int, string](55).mapErrIt(it & " bar")
      check res.successful()
      check res.getVal() == 55
