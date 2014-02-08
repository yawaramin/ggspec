;; ggspec - lightweight unit testing library for Guile
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(define-module (my ggspec)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-16)
  #:export
    (
    end
    error?
    suite
    options
    option
    setups
    setup
    tests
    test
    teardowns
    teardown
    text-verbose
    text-normal
    none
    suite-args
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

(define (println . args) (for-each display args) (newline))

(define (assert-equal-to output-cb expected got)
  "Checks that the expected value is equal to the received value. If
  not, sends failure messages to the output callback function.

  Arguments
  output-cb - proc that accepts any number of arguments: the output
  callback function to send messages to.

  expected - any: the expected value.

  got - any: the received value.

  Returns:
  #t if the expected and received values are equal. #f otherwise."
  (if (equal? expected got)
    (begin
      (output-cb #:assert-status 'pass)
      #t)
    (begin
      (output-cb #:expected expected #:got got #:assert-status 'fail)
      #f)))

(define (assert-not-equal-to output-cb not-expected got)
  "Like assert-equal-to, but checks that the specified value is not
  equal to the received value. If they are equal, sends failure messages
  to the output callback function."
  (if (equal? not-expected got)
    (begin
      (output-cb
        #:not-expected not-expected
        #:got got
        #:assert-status 'fail)
      #f)
    (begin
      (output-cb #:assert-status 'pass)
      #t)))

(define (assert-true-to output-cb x)
  (assert-equal-to output-cb #t (if x #t #f)))

(define (assert-false-to output-cb x)
  (assert-equal-to output-cb #f (if x #t #f)))

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
;;   Records all passed-in arguments as meta-information inside the
;;   suite procedure, in the property named 'args.

;; Returns
;;   (list num-passes num-fails)

;;     num-passes: number: the number of passed tests.
;;     num-fails: number: the number of failed tests.
(define suite
  (case-lambda
    ((desc tsts opts sups tdowns)
      (define output-cb
        (let ((v (assoc-ref opts 'output-cb))) (if v v text-normal)))
      (output-cb #:suite-desc desc)

      (let*
        ((suite-bindings
          (list
            (cons
              'assert-equal
              (lambda (expected got)
                (assert-equal-to output-cb expected got)))
            (cons
              'assert-not-equal
              (lambda (expected got)
                (assert-not-equal-to output-cb expected got)))
            (cons
              'assert-true
              (lambda (x) (assert-true-to output-cb x)))
            (cons
              'assert-false
              (lambda (x) (assert-false-to output-cb x)))))
        (intermediate-results
          (map
            (lambda (tst)
              (define test-desc (car tst))
              (define test-bindings
                (append
                  suite-bindings
                  (map
                    (lambda (sup) (cons (car sup) ((cdr sup))))
                    (or sups end))))
              (define (env name) (assoc-ref test-bindings name))
              (output-cb #:test-desc test-desc)
              (let
                ;; Run the test's function:
                ((result ((caddr tst) env)))
                ;; Run all the teardowns thunks:
                (for-each (lambda (td) (td)) tdowns)
                (output-cb #:test-status (if result 'pass 'fail))
                result))
            (or tsts end)))
        (num-tests
          (length intermediate-results))
        (num-passes
          (length (filter identity intermediate-results))))

        (output-cb #:suite-status 'complete)
        (list num-passes (- num-tests num-passes))))
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

;;   expr ...: a variable number of expressions that make up the body of
;;   the test. These will be wrapped inside a function and the function
;;   will be passed in the 'environment' env from above.

;; Returns
;;   (list desc opts func): a three-member list of the test description,
;;   the options passed in to the test, and the unevaluated function
;;   making up the body of the test.
(define-syntax test
  (syntax-rules ()
    ((_ desc env expr ...)
      (list desc end (lambda (env) expr ...)))))

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

  (if-let suite-desc (kw 'suite-desc)
    (println "  Suite: " suite-desc))

  (if-let test-desc (kw 'test-desc)
    (println "    Test: " test-desc))

  (if-let test-status (kw 'test-status)
    (if (equal? test-status 'fail)
      (println "    [FAIL]")
      ;; Otherwise, the test passed.
      (println "    [PASS]")))

  ;; We definitely want to know if any asserts failed.
  (if-let assert-status (kw 'assert-status)
    (if (equal? assert-status 'fail)
      (if-let got (kw 'got)
        (if-let expected (kw 'expected)
          (begin
            (println "      Expected: " expected)
            (println "      Got: " got))
          (if-let not-expected (kw 'not-expected)
            (begin
              (println "      Expected: not " not-expected)
              (println "      Got: " got))))
        (println "      Assert failed: details unavailable"))))

  (if-let suite-status (kw 'suite-status)
    (newline)))

(define none stubf)

