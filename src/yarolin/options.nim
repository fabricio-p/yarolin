import std/options
export options

import macros

template `?`*[T](ty: typedesc[T]): untyped = Option[T]

macro `or`*[T](option: Option[T], body: untyped): untyped =
  let optionSym = genSym(ident = "option")
  quote do:
    let `optionSym` = `option`
    if `optionSym`.isSome():
      `optionSym`.unsafeGet()
    else:
      `body`

macro `<->`*[T](option1, option2: sink Option[T]): T =
  let optionSym = genSym(ident = "optionLhs")
  quote do:
    let `optionSym` = `option1`
    if `optionSym`.isSome():
      `optionSym`.unsafeGet()
    else:
      `option2`.get()
