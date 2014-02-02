;; ggspec - lightweight unit testing library for GNU Guile (and other
;; Schemes?)
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(define-module (my ggspec)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-16)
  #:use-module (ice-9 receive)
  #:export
    (
    end
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
    suite-passes
    suite-fails
    ))

(define (stub retval)
  "Stubs a function to return a canned value.

  Arguments:
  retval - any: the canned value to return.

  Returns:
  A function that takes any combination of arguments and returns the
  canned value."
  (lambda args retval))

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
;;   (lambda ()
;;     (list desc pass-list fail-list)

;;       pass-list: (list desc ...)
;;       fail-list: (list desc ...)

;;         desc: string: a description.

;;   An uncalled procedure which, when called, will return the results
;;   of running the test suite.
(define suite
  (case-lambda
    ((desc tsts opts sups tdowns)
      (set-procedure-property!
        suite
        'args
        (list desc opts sups tsts tdowns))

      (lambda ()
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

          ;; Intermediate result structure:
          ;;
          ;; (list
          ;;   (cons 'pass desc) ...
          ;;   (cons 'fail desc) ...)
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
                  ;; Run the test's thunk:
                  ((result ((caddr tst) env)))
                  ;; Run all the teardowns thunks:
                  (for-each (lambda (td) (td)) tdowns)
                  (cons
                    (if result
                      (begin
                        (output-cb #:test-status 'pass)
                        'pass)
                      (begin
                        (output-cb #:test-status 'fail)
                        'fail))
                    test-desc)))
              (or tsts end))))

          (receive (passes fails)
            (partition
              (lambda (result) (equal? 'pass (car result)))
              intermediate-results)
            (list desc (map cdr passes) (map cdr fails))))))
    ((desc tsts) (suite desc tsts end end end))
    ((desc tsts opts) (suite desc tsts opts end end))
    ((desc tsts opts sups) (suite desc tsts opts sups end))))

(define options list)
(define option cons)
(define setups list)
(define setup cons)
(define tests list)

;; Declares a test.

;; Arguments
;;   desc: string: a description of the test.

;;   thunk: (lambda () expr ...): a function that takes no arguments and
;;   returns either #t (test passed) or #f (test failed).

;;   opts: same as the opts passed into the suite function, see above.

;; Returns
;;   (list desc thunk opts): a two-member list of the unevaluated thunk
;;   and the options passed in to the test.
(define test
  (case-lambda
    ((desc thunk opts) (list desc opts thunk))
    ((desc thunk) (test desc thunk end))))

(define teardowns list)
(define teardown identity)
(define text-verbose stubf)

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
  (define (when-then-print sym msg)
    (if (assoc sym kws)
      (println msg (assoc-ref kws sym))))

  (when-then-print 'suite-desc "  Suite: ")
  (when-then-print 'test-status "    Test "))

(define none stubf)

(define (suite-passes s) (cadr s))
(define (suite-fails s) (caddr s))
(define (suite-args) (procedure-property suite 'args))

