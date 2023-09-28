#######
yarolin
#######
**WIP**

A library offering feature complete functionality for options and results.

=====
Usage
=====
Add this line to your ``.nimble`` file:

.. code-block:: nim

  requires "https://github.com/fabriciopashaj/yarolin"

and then you can import it in your project.

-------
Results
-------
.. code-block:: nim

  import yarolin/results

  proc foo(): void!int =
    result =!- 420
  proc bar(): string!void =
    result =!+ "Hello world"

  echo foo().getErr() # prints "420"
  echo bar().getVal() # prints "Hello world"

-------
Options
-------
.. code-block:: nim

  import yarolin/options

  proc at[T](arr: openArray[T], i: int): ?T =
    if i in 0..arr.high:
      return some(arr[i])
    return none(T)

  let a = @[1, 2, 3]
  echo a.at(0).get() # prints "1"
  echo a.at(100).isSome() # prints "false"

.. code-block:: nim

    import strtabs, strutils
    import yarolin/options

    type Config = object
      width, height, fontSize: int
      font: string

    func get(strtab: StringTableRef, key: string): ?string =
      if strtab.hasKey(key):
        return some(strtab[key])
      result = none(string)

    func getConfig(strtab: StringTableRef): Config =
      Config(
        width: strtab.get("width").map(parseInt) or 680,
        height: strtab.get("height").map(parseInt) or 460,
        fontSize: strtab.get("fontSize").map(parseInt) or 30,
        font: strtab.get("font") or "monospace")
====
TODO
====
- ☐ Results.

  - ☑ ``Result[V, E]`` type optimised for pointer types.
  - ☑ Basic functionality.

    - ☑ ``success`` and ``failure`` functions that wrap a value into a success or failure result.
    - ☑ ``successful`` function that checks if result is a success.
    - ☑ ``unsuccessful`` function that checks if result is a failure.
    - ☑ ``unsafeGetVal`` and ``unsafeGetErr`` functions to get a raw pointer to the value or error that the result holds.
    - ☑ ``getVal`` and ``getValErr`` functions that unwrap the value or error of a result.
      - ``getVal`` throws an ``UnpackValDefect`` when the result is a failure.
      - ``getErr`` throws an ``UnpackErrDefect`` when the result is a success.

  - ☐ Utility macros and functions.

    - ☑ ``!`` binary operator that makes a ``Result`` type.
    - ☑ ``!+`` and ``!-`` binary operators.
    - ☑ ``=!+`` and ``=!-`` binary operators.
    - ☑ ``returnVal`` and ``returnErr`` macros that do exactly what their name tells.
    - ☑ ``or`` operator that gets the value of ``lhs`` if it is a success result and executes ``rhs`` if otherwise.
    - ☑ ``try`` macro that causes the functions to return the result if it is a failure, otherwise just gives the value.
    - ☑ ``throw`` function that throws the error of the result as an exception if it is a failure, otherwise just gives the value.
    - ☑ ``with`` macro that does pattern matching on the result.
    - ☑ ``successfulAnd`` function that takes a predicate ``fn`` either returns the result of calling it on the value if the result is successful, or false.
    - ☑ ``unsuccessfulAnd`` is similar but when the result is unsuccessful and calls ``fn`` on the error instead.
    - ☑ ``successfulAndIt`` same as above but functions like the ``*It`` macros from sequtils.
    - ☑ ``unsuccessfulAndIt`` same as above but functions like the ``*It`` macros from sequtils.
    - ☑ ``mapVal`` either returns a success result with the value returned by the ``fn`` predicate called on the value if the result is successful, or a failure with the same error as the result.
    - ☑ ``mapValOr`` returns the either mapped value by the ``fn`` predicate or a default value if the result is unsuccessful.
    - ☑ ``mapValOrElse`` takes 2 predicate functions, one is called with the result's value if it is successful, the other with the error. Returns whatever they return.
    - ☑ ``mapErr`` like ``mapVal`` but the other way around (with the error).
    - ☑ ``mapValIt`` does the same as the one above, same difference as the other ``*It`` macros.
    - ☑ ``mapValOrIt`` (same).
    - ☑ ``mapValOrElseIt`` (same).
    - ☑ ``mapErrIt`` (same).
  - ☑ Tests

  - ☐ Documentation.

    - ☑ In code (heredocs, doc comments or smth).
    - ☐ In README.

      - ☑ Basic examples.
      - ☐ At least half of functionality.

- ☐ Options.

  - ☑ Reuse and expose ``std/options``.
  - ☐ Utility macros and functions.
    - ☑ ``?`` unary operator that creates an ``Option`` type.
    - ☑ ``or`` macro that gets the value of ``lhs`` if it is ``some`` otherwise executes ``rhs``.
    - ☑ ``<->``  operator that either unpacks ``lhs`` or ``rhs`` if ``lhs`` is none.
    - ☑ ``mapIt`` macro.
    - ☑ ``map2`` function that maps 2 options together.
    - ☑ ``map2AB`` macros that works like ``map2`` but takes and executes a tree with ``a`` as the value of ``lhs`` and ``b`` as the value of ``rhs`` instead of taking a calling a predicate function.
    - ☑ ``try`` macro.
    - ☑ ``orReturn`` macro.
    - ☑ ``isSomeAnd`` function.
    - ☑ ``isSomeAndIt`` macro.
