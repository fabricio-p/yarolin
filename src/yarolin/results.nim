when defined(nimHasEffectsOf):
  {.experimental: "strictEffects".}
else:
  {.pragma: effectsOf.}

when (NimMajor, NimMinor) >= (1, 1):
  type SomePointer = ref | ptr | pointer | proc
else:
  type SomePointer = ref | ptr | pointer

import macros, strformat

type
  Result*[V, E] = object
    val: V
    err: E
    when V isnot SomePointer and E isnot SomePointer:
      successful: bool
  UnwrapDefect = object of Defect
  UnwrapErrDefect = object of Defect

template `!`[E, V](err: typedesc[E], val: typedesc[V]): untyped = Result[V, E]

proc successful*[V, E](res: Result[V, E]): bool {.inline.} =
  when V is SomePointer:
    result = not isNil(res.val)
  elif E is SomePointer:
    result = isNil(res.err)
  else:
    result = res.successful

proc success*[V, E](val: sink V): Result[V, E] {.inline.} =
  result.val = val
  when V isnot SomePointer:
    result.successful = true
  when E is SomePointer:
    result.err = nil
proc failure*[V, E](err: sink E): Result[V, E] {.inline.} =
  result.err = err
  when E isnot SomePointer:
    result.successful = false
  when V is SomePointer:
    result.err = nil

proc unsafeGetVal*[V, E](res: Result[V, E]): ptr V {.inline.} = addr res.val
proc unsafeGetErr*[V, E](res: Result[V, E]): ptr E {.inline.} = addr res.err

proc unwrap*[V, E](res: sink Result[V, E]): V
                  {.inline, raises: [UnwrapDefect].} =
  if res.successful():
    result = res.val
  else:
    raise newException(
      UnwrapDefect,
      "Tried to unwrap the value of an failure Result")
proc unwrapErr*[V, E](res: sink Result[V, E]): E
                     {.inline, raises: [UnwrapErrDefect].} =
  if res.successful():
    raise newException(
      UnwrapErrDefect,
      "Tried to unwrap the error of a success Result")
  else:
    result = res.err

template `!+`*[V, E](resultType: typedesc[Result[V, E]], val: sink V): untyped =
  success[V, E](val)

template `!-`*[V, E](resultType: typedesc[Result[V, E]], err: sink E): untyped =
  failure[V, E](err)

template `=!+`*[V, E](res: var Result[V, E], val: sink V): untyped =
  res = success[V, E](val)

template `=!-`*[V, E](res: var Result[V, E], err: sink E): untyped =
  res = failure[V, E](err)

template `or`*[V, E](res: Result[V, E], body: untyped): untyped =
  if res.successful():
    res.unsafeGetVal()[]
  else:
    body
