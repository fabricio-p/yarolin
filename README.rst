#######
yarolin
#######
A library offering feature complete functionality for options and results.

=====
Usage
=====
-------
Results
-------
.. code-block:: nim

  import yarolin/results

  proc foo(): void!int =
    result =!- 420
  proc bar(): string!void =
    result =!+ "Hello world"

  echo foo().unwrapErr() # prints "420"
  echo bar().unwrap() # prints "Hello world"

====
TODO
====
- ☐ Results.
  - ☑ `Result[V, E]` type optimised for pointer types.
  - ☑ Basic functionality.
    - ☑ `success` and `failure` functions that wrap a value into a success or failure result.
    - ☑ `successful` function that checks if result is a success or failure.
    - ☑ `unsafeGetVal` and `unsafeGetErr` functions to get a raw pointer to the value or error that the result holds.
    - ☑ `unwrap` and `unwrapErr` functions that unwrap the value or error of a result.
      * `unwrap` throws an `UnwrapDefect` when the result is a failure.
      * `unwrapErr` throws an `UnwrapErrDefect` when the result is a success.
  - ☐ Utility macros.
    - ☑ `!` binary operator that makes a `Result` type.
    - ☑ `or` macro that executes `rhs` if `.
    - ☑ `!+` and `!-` binary operators.
    - ☑ `=!+` and `=!-` binary operators.
    - ☑ `or` operator that unwraps the value of `lhs` if it is a success result and executes `rhs` if otherwise.
    - ☐ `try` macro that causes the functions to return the result if it is a failure, otherwise just gives the unwraped value.
    - ☐ `throw` that throws the error of the result as an exception if it is a failure, otherwise just gives the unwraped value..
    - ☐ `with` macro that does pattern matching on the result.
- ☐ Options.
  - ☑ Reuse and expose `std/options`.
  - ☐ Other stuff.
