import unittest, typetraits
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
