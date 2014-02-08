# ggspec - lightweight unit testing library for Guile

Copyright (c) 2014 Yawar Amin

See LICENSE file for details

GitHub, Reddit, Twitter: yawaramin

ggspec is a _very_ lightweight unit testing framework for Guile. I may
port it to other Schemes in future; in principle it should be fairly
simple because it doesn't use very many Guile-specific features.

ggspec is self-testing. In fact, it was bootstrapped by the tests--the
tests were written _first,_ before there was a unit testing framework to
run them; and _then_ the framework was written around the tests.

## Installation

### Guile

Put the `ggspec.scm` file inside a directory named `my` in your
`$GUILE_LOAD_PATH` (you can add your personal directories to this path).
E.g., I have `~/guile` in my load path. So the Scheme file is in:
`~/guile/my/ggspec.scm`.

## Minimal complete example

```
$ guile
guile> (use-modules (my ggspec))
guile> (define demo-suite (suite "Hello ggspec" end))
guile> (demo-suite)
  Suite: Hello ggspec
(0 0)
```

The last line above shows the number of passing tests and the number of
failing tests. Since we didn't write _any_ tests here, but are zero.

## Tutorial

See the `ggspec.scm` file for a detailed reference. A short tutorial (in
the context of Test-Driven Development):

Suppose we want to develop a function `sqr` that should return the
square of its argument (a number). In this example I will show the
function and its test suite together, but usually you would have them in
separate files.

First you write a failing test:

```scheme
(use-modules (my ggspec))

(define sqr-suite ; Nothing significant about the name sqr-suite.
  (suite "The sqr function"
    (tests
      (test "Should square 1 correctly"
        e
        ((e 'assert-equal) 1 (sqr 1))))))

(sqr-suite) ; Run the suite.
```

This suite will fail because the `sqr` function does not exist:

```
  Suite: The sqr function
ERROR: Unbound variable: sqr
```

Now implement it to make the test pass:

```scheme
(define (sqr x) 1)
```

The test will now pass because we have 'cheated' to make it so:

```
  Suite: The sqr function
    Test: Should square 1 correctly
    [PASS]
```

Now we extend the suite to another 'example':

```scheme
(use-modules (my ggspec))

(define sqr-suite ; Nothing significant about the name sqr-suite.
  (suite "The sqr function"
    (tests
      (test "Should square 1 correctly"
        e
        ((e 'assert-equal) 1 (sqr 1)))
      (test "Should square 2 correctly"
        e
        ((e 'assert-equal) 4 (sqr 2))))))

(sqr-suite)
```

This will now fail, again, because the `sqr` function is hard-coded to
always return `1`:

```
  Suite: The sqr function
    Test: Should square 1 correctly
    [PASS]
    Test: Should square 2 correctly
      Expected: 4
      Got: 1
    [FAIL]
```

Now we fix that:

```scheme
(define (sqr x) (* x x))
```

This time the test will pass because `sqr` handles the general case:

```
  Suite: The sqr function
    Test: Should square 1 correctly
    [PASS]
    Test: Should square 2 correctly
    [PASS]
```

