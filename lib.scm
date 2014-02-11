#!
ggspec lib - lightweight unit testing library for Guile

Copyright (c) 2014 Yawar Amin
GitHub, Reddit, Twitter: yawaramin

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
!#
(define-module (ggspec lib)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-16)
  #:export
    (
    assert-equal
    assert-not-equal
    assert-true
    assert-false
    assert-all
    end
    error?
    suite
    options
    option
    println
    range
    setups
    setup
    tests
    test
    teardowns
    teardown
    text-verbose
    text-normal
    none
    stub
    kwalist
    ))

(use-syntax (ice-9 syncase))

(define-syntax if-let
  (syntax-rules ()
    ((_ name val then-exp else-exp)
      (let ((name val)) (if name then-exp else-exp)))
    ((_ name val then-exp)
      (if-let name val then-exp #f))))

(define (stub retval)
  "Stubs a function to return a canned value.

  Arguments:
  retval - any: the canned value to return.

  Returns:
  A function that takes any combination of arguments and returns the
  canned value."
  (lambda _ retval))

;; A frequently-used stub.
(define stubf (stub #f))
(define end '())

#!
Creates a list of numbers in the range specified.

Arguments
  start: number: optional (default 0). The number to start at.

  stop: number: the number to stop at.

  step: number: optional (default 1). The difference between each number
  in the list.

Returns
  A list of numbers starting at 'start', incrementing by 'step', and
  stopping at exactly or at less than 'stop'. The list will stop at
  exactly 'stop' if all three arguments are integers. Otherwise it will
  stop when the last number in the list is smaller than 'stop'.
!#
(define range
  (case-lambda
    ((start stop step)
      (reverse
        (let loop
          ((stop stop)
          (start start)
          (step step)
          (result end))

          (if (>= start stop)
            result
            (loop stop (+ start step) step (cons start result))))))
    ((start stop) (range start stop 1))
    ((stop) (range 0 stop 1))))

(define (println . args) (for-each display args) (newline))

(define (assert-equal expected got)
  "Checks that the expected value is equal to the received value.

  Arguments
    expected: any: the expected value.

    got: any: the received value.

  Returns:
    (list assert-status expected #f got): a list made up of the status
    of the assertion and diagnostic details.

      assert-status: boolean: #t if the assert succeeded, #f otherwise.

      expected: any: the 'expected' value that was passed in to the
      function.

      #f: this is a flag that indicates that the 'expected' value is
      understood to be the actual expected value (see below).

      got: any: the 'got' value that was passed in to the function."
  (list (equal? expected got) expected #f got))

(define (assert-not-equal not-expected got)
  "Like assert-equal, but checks that the specified value is not equal
  to the received value.

  Arguments:
    not-expected: any: the value not expected.

    got: any: the received value.

  Returns
    Like 'assert-equal', but the third item in the list, the flag, is
    set to #t to indicate that the 'expected' value being passed back
    was actually _not_ expected."
  (list (not (equal? not-expected got)) not-expected #t got))

(define (assert-true x) (assert-equal #t (if x #t #f)))
(define (assert-false x) (assert-equal #f (if x #t #f)))

(define (assert-all . exprs)
  "Asserts all of the given assertions (see above).

  Arguments
    exprs: a variable number of assertions created with one of the above
    assertion functions.

  Returns
    A failure result from the first assertion that fails, if any; or a
    success result."
  (let loop
    ((exprs exprs))

    (if (null? exprs)
      (list #t #t #f #t)
      (let*
        ((first-expr (car exprs))
        (assert-status (car first-expr))
        (expected (cadr first-expr))
        (flag (caddr first-expr))
        (got (cadddr first-expr)))

        (if (not assert-status)
          (list #f expected flag got)
          (loop (cdr exprs)))))))

(define-syntax error?
  (syntax-rules ()
    ((_ expr) (catch #t (lambda () expr #f) (lambda _ #t)))))

;; Declares a test suite.

;; Arguments
;;   desc: string: description of the suite.

;;   tsts: (list tst ...): a collection of tests to run in this suite.

;;     tst: (list desc opts (lambda (e) expr))

;;       desc: string: description of the test.
;;       opts: same as above.
;;       expr: the body of the test.

;;   opts: (list opt ...): a collection of options to pass into the
;;   suite.

;;     opt:
;;       (list
;;         (cons opt-name opt-val) ...)

;;       opt-name: symbol: the name of the option.
;;       opt-val: any: the value being given to the option.

;;   sups: (list sup ...): a collection of setup names and values to
;;   pass into each test.

;;     sup: (cons sup-name sup-val)

;;       sup-name: symbol
;;       sup-val: (lambda () expr)

;;         expr: any: the value to be given to the setup variable
;;         during each test run. Will be re-evaluated each time a test
;;         is run.

;;   tdowns: (list tdown ...): a collection of teardowns to run after
;;   running each test.

;;     tdown: (teardown (lambda () body ...))

;;       body: the body expressions of the teardown.

;; Side Effects
;;   Outputs descriptive and diagnostic messages using the given runtime
;;   message ('output-cb') function.

;; Returns
;;   (list num-passes num-fails num-skips)

;;     num-passes: number: the number of passed tests.
;;     num-fails: number: the number of failed tests.
;;     num-skips number: the number of skipped tests.
(define suite
  (case-lambda
    ((desc tsts opts sups tdowns)
      (define output-cb
        (if-let v (assoc-ref opts 'output-cb) v text-normal))
      (define colour (if-let v (assoc-ref opts 'colour) v))
      (define num-tests (length tsts))

      (output-cb #:suite-desc desc)
      (output-cb #:num-tests num-tests)
      (let*
        ((suite-bindings
          (list
            (cons
              'assert-equal
              (lambda (expected got)
                (assert-equal expected got)))
            (cons
              'assert-not-equal
              (lambda (expected got)
                (assert-not-equal expected got)))
            (cons
              'assert-true
              (lambda (x) (assert-true x)))
            (cons
              'assert-false
              (lambda (x) (assert-false x)))))
        (intermediate-results
          (map
            (lambda (tst tst-num)
              (define test-desc (car tst))
              (define test-bindings
                (append
                  suite-bindings
                  (map
                    (lambda (sup) (cons (car sup) ((cdr sup))))
                    (or sups end))))
              (define (env name) (assoc-ref test-bindings name))

              (let*
                ;; Run the test's function:
                ((result ((caddr tst) env))
                ;; Extract parts of each result:
                (assert-status (car result))
                (expected (cadr result))
                (flag (caddr result))
                (got (cadddr result)))

                ;; Run all the teardowns thunks:
                (for-each (lambda (td) (td)) tdowns)
                (output-cb
                  #:colour colour
                  #:test-num tst-num
                  #:test-desc test-desc
                  #:assert-status assert-status
                  #:got got
                  (if flag #:expected #:not-expected) expected)
                assert-status))
            (or tsts end)
            (range 1 (+ num-tests 1))))
        (num-passes
          (length (filter identity intermediate-results))))

        (output-cb #:suite-status 'complete)
        (list num-passes (- num-tests num-passes) 0)))
    ((desc tsts) (suite desc tsts end end end))
    ((desc tsts opts) (suite desc tsts opts end end))
    ((desc tsts opts sups) (suite desc tsts opts sups end))))

(define options list)
(define option cons)
(define setups list)

;; Declares a setup symbol-binding.

;; Arguments
;;   sym: symbol: a symbol by which to refer to the bound value.

;;   expr: any: a value to bind to the symbol above. This value may
;;   later be accessed from any test in the same suite by calling the
;;   test's 'environment' (usually e) with the symbol. E.g., (e 'sym).
(define-syntax setup
  (syntax-rules ()
    ((_ sym expr)
      (cons sym (lambda () expr)))))

(define tests list)

;; Declares a test.

;; Arguments
;;   desc: string: a description of the test.

;;   env: an 'environment' (an alist of names and bindings) that is
;;   passed in to the test. Two types of names are defined:

;;     1. Names always automatically defined by ggspec before running
;;     the test: 'assert-equal, 'assert-not-equal, etc. These are
;;     defined by ggspec automatically because they depend on the suite
;;     options like where to send test runtime messages to.

;;     2. Names defined by the test writer by setting up names and
;;     corresponding values in the suite setup section. The
;;     corresponding values are evaluated anew each time a test is run,
;;     which is why in the setup section you have to wrap each value up
;;     inside a thunk.

;;     expr: a value returned by one of the above assertion functions.
;;     An expression that makes up the body of the test. This will be
;;     wrapped inside a function and the function will be passed in the
;;     'environment' env from above.

;;   opts: same type as in 'suite', above.

;; Returns
;;   (list desc opts func): a three-member list of the test description,
;;   the options passed in to the test, and the unevaluated function
;;   making up the body of the test.
(define-syntax test
  (syntax-rules ()
    ((_ desc env expr opts)
      (list desc opts (lambda (env) expr)))
    ((_ desc env expr)
      (test desc env expr end))))

(define teardowns list)

;; Declares a teardown.

;; Arguments
;;   expr ...: any number of expressions.

;; Returns
;;   A thunk containing all the expressions above, ready to be
;;   evaluated.
(define-syntax teardown
  (syntax-rules ()
    ((_ expr ...) (lambda () expr ...))))

(define (kwalist arglist)
  "Turn a list of keyword arguments into an alist of symbols and
  values.

  Arguments
    arglist: (list #:kw1 arg1 ...)

  Returns
    (list (cons sym1 arg1) ...)"
  (cond
    ((null? arglist) end)
    ((= 1 (length arglist)) (error "Keyword argument error"))
    (#t
      (cons
        (cons
          (keyword->symbol (car arglist))
          (cadr arglist))
        (kwalist (cddr arglist))))))

(define (text-verbose . kwargs)
  (define kws (kwalist kwargs))
  (define (when-then-print sym msg)
    (if (assoc sym kws)
      (println msg (assoc-ref kws sym))))

  (when-then-print 'suite-desc "  Suite: ")
  (when-then-print 'test-desc "    Test: ")
  (when-then-print 'expected "      Expected: ")
  (when-then-print 'not-expected "      Not expected: ")
  (when-then-print 'got "      Got: ")
  (when-then-print 'assert-status "      Assert ")
  (when-then-print 'test-status "    Test "))

(define (text-normal . kwargs)
  (define kws (kwalist kwargs))
  (define (kw sym) (assoc-ref kws sym))

  (define colour-red
    (if-let v (kw 'colour) "\x1b[31m" ""))
  (define colour-green
    (if (equal? colour-red "") "" "\x1b[32m"))
  (define colour-normal
    (if (equal? colour-red "") "" "\x1b[0m"))

  (if-let suite-desc (kw 'suite-desc)
    (println "  Suite: " suite-desc))

  (if-let test-desc (kw 'test-desc)
    (println "    Test: " test-desc))

  (if-let test-status (kw 'test-status)
    (if (equal? test-status 'fail)
      (println "    " colour-red "[FAIL]" colour-normal)
      ;; Otherwise, the test passed.
      (println "    " colour-green "[PASS]" colour-normal)))

  ;; We definitely want to know if any asserts failed.
  (if-let assert-status (kw 'assert-status)
    (if (equal? assert-status 'fail)
      (if-let got (kw 'got)
        (if-let expected (kw 'expected)
          (begin
            (println "      Expected: " expected)
            (println "           Got: " got))
          (if-let not-expected (kw 'not-expected)
            (begin
              (println "      Expected: not " not-expected)
              (println "           Got: " got))))
        (println "      Assert failed: details unavailable"))))

  (if-let suite-status (kw 'suite-status)
    (newline)))

(define none stubf)

