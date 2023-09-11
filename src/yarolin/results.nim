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
  if not res.successful():
    result = res.err
  else:
    raise newException(
      UnwrapErrDefect,
      "Tried to unwrap the error of a success Result")

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

macro `try`*[V, E](res: Result[V, E]): untyped =
  let resSym = genSym(ident = "res")
  quote do:
    let `resSym` = `res`
    if `resSym`.successful():
      `resSym`.unsafeGetVal()[]
    else:
      result =!- `resSym`.unsafeGetErr()[]
      return

func throw*[V, E, X](res: sink Result[V, E], errorType: typedesc[X]): V =
  if res.successful():
    return res.unsafeGetVal()[]
  else:
    raise newException(X, $(res.unsafeGetErr()[]))

func throw*[V, E](res: sink Result[V, E]): V =
  return res.throw(CatchableError)

macro with*[V, E](res: Result[V, E], body: untyped): untyped =
  let resSym = genSym(ident = "res")
  body.expectLen 1, 2
  result =
    nnkStmtList.newTree(
      nnkLetSection.newTree(
        nnkIdentDefs.newTree(
          resSym,
          newEmptyNode(),
          res)))
  var
    onFailure: NimNode = nil
    onSuccess: NimNode = nil
  for `case` in body:
    `case`.expectKind nnkCall
    `case`.expectLen 3
    `case`[0].expectKind nnkIdent
    `case`[1].expectKind { nnkIdent, nnkVarTy }
    var branch =
      if `case`[0].strVal == "successful":
        onSuccess = nnkStmtList.newNimNode()
        onSuccess
      elif `case`[0].strVal == "failure":
        onFailure = nnkStmtList.newNimNode()
        onFailure
      else:
        error(
          fmt"Expected 'successful' or 'failure', found {`case`[0].strVal}",
          `case`[0])
        break
    let
      (isMutable, varName) =
        if `case`[1].kind == nnkIdent: (false, `case`[1])
        else: (true, `case`[1][0])
      varDecl = 
        if varName.strVal == "_":
          newEmptyNode()
        else:
          newTree(
            if isMutable: nnkVarSection else: nnkLetSection,
            nnkIdentDefs.newTree(
              varName,
              newEmptyNode(),
              nnkBracketExpr.newTree(
                nnkCall.newTree(
                  if branch == onFailure: bindSym"unsafeGetErr"
                  else: bindSym"unsafeGetVal",
                  resSym))))
    branch.add(nnkStmtList.newTree(varDecl, `case`[2]))
  var
    ifStmt = nnkIfStmt.newNimNode()
    elifBrach = nnkElifBranch.newNimNode()
    elseBranch: NimNode = nil
  var
    cond = nnkCall.newTree(bindSym"successful", resSym)
    actions = onSuccess
  if isNil(onSuccess):
    cond = nnkPrefix.newTree(bindSym"not", cond)
    actions = onFailure
  elif body.len == 2:
    elseBranch = nnkElse.newTree(onFailure)
  elifBrach.add(cond, actions)
  ifStmt.add(elifBrach)
  if not isNil(elseBranch):
    ifStmt.add(elseBranch)
  result.add(ifStmt)
