import std/options
export options

import macros

template `?`*[T](ty: typedesc[T]): untyped = Option[T]

macro `or`*[T](opt: Option[T], body: untyped): untyped =
  let optSym = genSym(ident = "opt")
  quote do:
    let `optSym` = `opt`
    if `optSym`.isSome():
      `optSym`.unsafeGet()
    else:
      `body`

macro `<->`*[T](opt1, opt2: sink Option[T]): T =
  let optSym = genSym(ident = "optLhs")
  quote do:
    let `optSym` = `opt1`
    if `optSym`.isSome():
      `optSym`.unsafeGet()
    else:
      `opt2`.get()

macro mapIt*[T](opt: sink Option[T], body: untyped): untyped =
  let
    optSym = genSym(ident = "opt")
    tSym = genSym(kind = nskType, ident = "T")
  quote do:
    let `optSym` = `opt`
    if `optSym`.isSome():
      let it {.inject.} = `optSym`.unsafeGet()
      some(`body`)
    else:
      type `tSym` = typeof(block:
        var it {.inject, noinit.}: `optSym`.T
        `body`)
      none(`tSym`)

proc map2*[V1, V2, V3](opt1: Option[V1],
                       opt2: Option[V2],
                       fn: proc(a: V1, b: V2): V3): Option[V3]
                      {.effectsOf: fn.} =
  if opt1.isSome() and opt2.isSome():
    return some(fn(opt1.unsafeGet(), opt2.unsafeGet()))
  none(V3)

macro map2AB*[V1, V2](opt1: Option[V1],
                      opt2: Option[V2],
                      body: untyped): untyped =
  let
    opt1Sym = genSym(ident = "opt1")
    opt2Sym = genSym(ident = "opt2")
    v3Sym = genSym(kind = nskType, ident = "V3")
  quote do:
    let
      `opt1Sym` = `opt1`
      `opt2Sym` = `opt2`
    if `opt1Sym`.isSome() and `opt2Sym`.isSome():
      let
        a {.inject.} = `opt1Sym`.unsafeGet()
        b {.inject.} = `opt2Sym`.unsafeGet()
      some(`body`)
    else:
      type `v3Sym` = typeof(block:
        var
          a {.inject, noinit.}: `opt1Sym`.T
          b {.inject, noinit.}: `opt2Sym`.T
        `body`)
      none(`v3Sym`)
