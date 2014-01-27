# ggspec - lightweight unit testing library for GNU Guile

(and other Schemes?)

Copyright 2014 Yawar Amin

See LICENSE file for details

GitHub, Reddit, Twitter: yawaramin

ggspec is a _very_ lightweight unit testing framework for Scheme(s). I am
using it on GNU Guile 1.8.8 but it's very minimal (no external
dependencies) so it will likely run on other Schemes after getting rid
of the Guile `define-module` function at the top.

Also, ggspec is now self-testing. Run the `test-ggspec.scm` file to see
a demonstration.

## Installation

### Guile

Put the `ggspec.scm` file inside a directory named `my` in your
`$GUILE_LOAD_PATH` (you can add your personal directories to this path).
E.g., I have `~/guile` in my load path. So the Scheme file is in:
`~/guile/my/ggspec.scm`.

### Others

Delete the `define-module` function call from the beginning of the
source code, drop the file anywhere you want to use it, and load it
using your Scheme's file loading function.

## Minimal complete example

    guile> (use-modules (my ggspec))
    guile> (run-suite "Hello ggspec" end end end)
      Hello ggspec
      0 test(s), 0 failure(s).
    guile>

## Motivation

There are a few Scheme unit test frameworks out in the wild; even the
'semi-official' guile-lib `(unit-test)`. _But_--they all seem to be
either heavily object-oriented, or not exactly compatible with Guile, or
just little bits of code floating around without clear documentation. So
I decided to just roll my own lightweight unit test framework with the
very basics. Also, I started with the goal of being as purely functional
as possible; but I did take advantage in some places of Scheme's
laid-back approach to impure code.

I'm by no means a Scheme guru, so I've avoided things like macros and
read table modifications and instead used lambdas and alists and also
some trickery that might make some people cringe. But it actually does
work and it looks OK if you squint at it in kind of the right way and it
doesn't depend on anything except some really basic Scheme.  So I have a
feeling (but nothing more solid) that it will run easily on most
implementations, including Racket.

## Documentation

See the end of the `ggspec.scm` file for a demonstration. A detailed
reference:

### run-suite

Defines and runs a test suite.

Arguments:

`suite-desc` - string: a description of the test suite
  
`setup-specs` - alist of symbols to functions which don't take any
arguments, and return one value

This association list is used to set up an 'environment' of names and
their associated values. If you're familiar with the xUnit style, this
is analogous to the `setUp()` function in each test suite class that
sets up frequently-used values which can then be accessed by each test
case. Accessing the values in ggspec is explained later.

Building the `setup-specs` alist is simplified with a little definition
trickery. The `setup` and `end` names are aliased to the `acons`
function so that:

    (setup 'x (lambda () 1)
    (setup 'y (lambda () 2)
    (setup 'z (lambda () 3)
    end)))

... becomes:

    (acons
      'x
      (lambda () 1)
      (acons
        'y
        (lambda () 2)
        (acons
          'z
          (lambda () 3)
          '())))

(Note: I'm using the function name `acons`, which may not be available
in all Schemes; but it's the same thing as SRFI-1's `alist-cons`.)

`test-specs` - alist of strings to functions which take a single
  argument and return either `#t` (success) or `#f` (failure)

This alist is used to run the actual tests. Each test spec is a pair
made up of a string describing the test and a function which carries out
the test.

The function takes a single argument `e`--the 'environment' which was
previously defined by `setup-specs`--and returns a boolean to indicate
test pass or fail. (You must define the function with the `e` parameter
whether you defined any setup specs earlier or not). If you defined
any setup specs earlier, you can access their values by calling `e` with
the name given to the set up variable:

    (e 'x) => 1
    (e 'y) => 2
    (e 'z) => 3

Again, building the test specs alist is simplified with some similar
definition trickery. The `run-test` name is aliased so that:

    (run-test "x plus y should equal z"
      (lambda (e)
        (assert-equal (e 'z) (+ (e 'x) (e 'y))))
    (run-test "x minus y should not equal z"
      (lambda (e)
        (assert-not-equal (e 'z) (- (e 'x) (e 'y))))
    (run-test "z divided by y should have quotient x"
      (lambda (e)
        (assert-equal (e 'x) (quotient (e 'z) (e 'y))))
    end)))

... expands out to the proper alist, as explained above.

`teardown-funcs` - list (not alist) of functions which take a single
value and don't (intentionally) return anything

The teardown functions are each called with the 'environment' (`e`) that
was initially defined in the suite. If you don't have any teardown to do
you can pass in an empty list, or the `end` name which has been bound to
the empty list:

    (run-suite "Demo"
      ... ;; setup-specs
      ... ;; test-specs
      end) ;; teardown-funcs

Returns:

A pair of: (_total number of tests run_ . _total number of failed
tests_).

### assert-equal

Checks whether the expected and actual values are equal.

Arguments:

`expected` - any: the expected value

`got` - any: the actual value

If the two differ, immediately prints the actual and expected values.

Returns:

`#t` if the expected and received values are the same; `#f` otherwise.

### assert-not-equal

Like `assert-equal`, but checks that the opposite is true.

Arguments:

`not-expected` - any

`got` - any

If the two are the same, immediately prints the values.

Returns:

`#t` if the expected and receive values differ; `#f` otherwise.

### assert-true

Checks whether something is true.

Arguments:

- `x` - any

If `x` evaluates to `#f`, immediately prints it.

Returns:

The truth value of `x`.

### run-test, setup

As explained above, these are aliases for the `acons` Scheme function to
provide a little 'syntactic sugar' for building up lists of setup and
test specs.

### teardown

This is also an alias: for the `cons` function. You can use it to
organise a set of functions to be run as teardown functions after each
(and every) test:

    (run-suite "Demo"
      ...
      ...
      (teardown
        (lambda (e) ...)
      (teardown
        (lambda (e) ...)
      end)))

### stub

Creates a 'stub' for any function.

The stub is a function that can take any combination of function
arguments and will return a predefined value.

Arguments:

`retval` - any: the predefined value that the stub should return

Returns:

A function that takes any combination of arguments and always returns
`retval`.

Stubbing is useful when you want to test functions in isolation from
each others' effects. It lets you 'hold all other things equal' (by
giving all those other function calls predefined return values) while
you test one thing (the current test).

### end

This is just the empty list; again, to help provide a more
natural-looking way to construct setups and tests.

Also, a nice way to finish off the reference.

