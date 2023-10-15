#######
yarolin
#######

A library offering feature complete functionality for options and results. Has the look of a mixup between rust and zig results/options. Feature requests are welcome. PRs not so much.

=====
Usage
=====
Add this line to your ``.nimble`` file:

.. code-block:: nim

  requires "https://github.com/fabriciopashaj/yarolin"

and then you can import it in your project.

-----
Intro
-----
Most of people today (2023-10-09) already have some sort of idea what results and options are, but anyway I'm going to explain them to showcase the features of the library. Results and options, in the theoretical aspect, are monads (also known as the sentence with the same amount of meaning (or lack thereof) "monoids in the category of endofunctors"). That's all I remember correctly about their theoretical nature. Oh, and by the way, the monad is not just the data structure (struct, record, object, whatever you call it), but also a special group of functions that operate on them, such as ``map`` and ``filter``.

Monads are a very clean way to encapsulate explicit control flow and branching into a more linear structure, by encapsulating the operations on the values and handling the other details themselves. Your average control flow adventures may include checking if a value is something like ``null``, checking the status of an operation, looping, etc and doing something different on each case. With results and options you just specify the name of the operation and the operation itself. The branching is handled by the functions of the monad.

..

  *FUN FACT*: Lists and arrays with their ``map`` and ``filter`` functions/methods are monads.

..

-------
Results
-------
Result is a monad represented by two variants, a success one and a failure one and a bunch of those fancy functions I mentioned earlier. In Nim slang those variants are like a ``case`` object with only 2 ``of`` branches. I don't know what to say more about it, you just use a success result with some value to indicate a successful operation that yields said value and a failure result with some other value (called an error) to indicate the failure of an operation with said error describing the failure.

The basic way to create result type is created like this:

.. code-block:: nim

    # Form
    Result[ValueType, ErrorType]
    # Example
    Results[int, string]
    Result[void, int]

Yarolin also offers the ``!`` operator, as a way to specify a result type in less keystrokes.

.. code-block:: nim

    # Form
    ErrorType!ValueType
    # Example
    string!int
    int!void

Now you may ask "Why is the order of the types reversed with the ``!`` operator?" and the answer is simply that this was inspired by the ``!`` type from Zig.
Actually creating a result is done like this:

.. code-block:: nim

    # Form
    success[ValueType, ErrorType](value)
    failure[ValueType, ErrorType](error)
    # Example
    success[int, string](420)
    failure[int, string]("oh no, x thing caused failure")
    success[void, int]()
    failure[void, int](1)

There's also another way with the ``!+`` and ``!-`` operators (because why not):

.. code-block:: nim

    # Form
    ResultType !+ value
    ResultType !- error
    # Example
    Result[int, string] !+ 420
    Result[int, string] !- "oh no, x thing caused failure"
    Result[void, int] !- 1
    string!int !+ 420
    string!int !- "oh no, x thing caused failure"
    int!void !- 1

Also there is *another* way to make a result, or should I say, assigning a result to a variable.

.. code-block:: nim

    # Form
    resultVar =!+ value
    resultVar =!- error
    # Example
    proc foo(fail: bool): Result[int, string] =
      if fail:
        result =!- "you told me to do it"
      else:
        result =!+ 420

The types are infered by the macro (not the type system). The macro basically expand to ``result = failure[result.V, result.E]("you told me to do it")`` and ``result = success[result.V, result.E](420)``.

Putting a value/error inside a result isn't that useful if you can't get it out. That is done like this:

.. code-block:: nim

    # Form
    res.getVal()
    res.getErr()

If you try and pull out the value out of a failure result or the error out of a success result a defect (or panic as some call it) is raised.
You can also access the value and the error as below:

.. code-block:: nim

    res.unsafeGetVal()
    res.unsafeGetErr()
    res.borrowVal()
    res.borrowErr()

The first two functions return a raw pointer to the value/error for you to do whatever you want, the last two return a ``var`` to the value/error with the intention of inplace modifications.

Checking the status of a result is done like this:

.. code-block:: nim

    res.successful() # `true` if `res` is a success result, `false` otherwise
    res.unsuccessful() # the opposite

Now we got a bunch of other macros.
The ``returnVal`` and ``returnErr`` the function they are expanded in to return a value wrapped inside a result.

.. code-block:: nim

    import parseutils

    proc readInt(): void!int =
      var
        line = ""
        value = 0
      stdin.readLine(line)
      if line.parseInt(value) == 0:
        returnErr()
      returnVal value

The ``or`` operator that unwraps the value of the ``lhs`` if it is a success result or the value that gets produced by evaluating ``rhs``.

.. code-block:: nim

    # doesn't quit, `rhs` is not evaluated
    echo success[int, string](20) or (quit(1); 0)
    # prints `-20`
    echo failure[int, string]("boo") or -20

The ``orReturn`` macro that unwraps the value of the result if it is a success one or causes the function from where it is expanded to return the value you specify.

.. code-block:: nim

    proc processInput(): int =
      let value = readInt().orReturn 0
      result = value * 10

The ``try`` macro that uwraps the value of the result if it is the succes one or causes the function inside which it is expanded to return a failure result with the error of the result we ``try``-ed as error. Must be used as ``res.try`` as ``try`` is a keyword and you can only call it as a method.

.. code-block:: nim

    proc processInput(): void!int =
      # Will propagate up the call stack on failure
      let value = readInt().try
      result =!+ value * 10

.. TODO: Add more examples and stuff.

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

=============
Documentation
=============
The explanation and documentation in this README is not sufficient at all, so there is an online version of the documentation `here <https://fabriciopashaj.github.io/yarolin>`_ generated by ``nimdoc``. You can also run the nimble task

.. code-block:: bash

    nimble docs_gen

to generate them localy.
