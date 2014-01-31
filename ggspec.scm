;; ggspec - lightweight unit testing library for GNU Guile (and other
;; Schemes?)
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(define-module (my ggspec)
  #:use-module (ice-9 optargs)
  #:export
    (
    assert-equal
    assert-false
    assert-not-equal
    assert-true
    end
    run-suite
    run-test
    setup
    stub
    stubf
    teardown
    ))

(define (ggspec-acons k v alist) (cons (cons k v) alist))
(define setup ggspec-acons)
(define run-test ggspec-acons)

(define (stub retval)
  "Stubs a function to return a canned value.

  Arguments:
  `retval` - any: the canned value to return.

  Returns:
  A function that takes any combination of arguments and returns the
  canned value."
  (lambda args retval))

;; A frequently-used stub.
(define stubf (stub #f))
(define teardown cons)
(define end '())

(define (println . args) (for-each display args) (display #\newline))

(define (assert-equal-to output-cb expected got)
  "Checks that the expected value is equal to the received value. If
  not, sends failure messages to the output callback function.

  Arguments:
  `output-cb` - proc that accepts any number of arguments: the output
  callback function to send messages to.

  `expected` - any: the expected value.

  `got` - any: the received value.

  Returns:
  `#t` if the expected and received values are equal. `#f` otherwise."
  (if (equal? expected got)
    (begin
      (output-cb #:status 'pass)
      #t)
    (begin
      (output-cb #:expected expected #:got got #:status 'fail)
      #f)))

(define (assert-not-equal-to output-cb not-expected got)
  "Like `assert-equal-to`, but checks that the specified value is not
  equal to the received value. If they are equal, sends failure messages
  to the output callback function."
  (if (equal? not-expected got)
    (begin
      (output-cb #:not-expected not-expected #:got got #:status 'fail)
      #f)
    (begin
      (output-cb #:status 'pass)
      #t)))

(define (assert-true-to output-cb x)
  (assert-equal-to output-cb #t (if x #t #f)))

(define (assert-false-to output-cb x)
  (assert-equal-to output-cb #f (if x #t #f)))

(define (run-suite suite-desc setup-specs test-specs teardown-funcs)
  (println "  " suite-desc)
  (let*
    ((results
      (map
        (lambda (test-spec)
          (define bindings
            (map
              (lambda (pair) (cons (car pair) ((cdr pair))))
              (or setup-specs end)))
          (define (env name) (assoc-ref bindings name))
          (define desc (car test-spec))
          (define test (cdr test-spec))
          ;; Have to print the test description first because the test
          ;; functions might write their own output to screen.
          (println "    " desc)
          (let ((result (test env)))
            (for-each (lambda (f) (f env)) (or teardown-funcs end))
            (if (not result) (println "      => FAIL"))
            result))
        (or test-specs end)))
    (total (length results))
    (successes (length (filter identity results)))
    (failures (- total successes)))
    (println "  " total " test(s), " failures " failure(s).")
    (cons total failures)))

