;; ggspec - lightweight unit testing library for GNU Guile (and other
;; Schemes?)
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(define-module (my ggspec)
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
    teardown
    ))

(define (ggspec-acons k v alist) (cons (cons k v) alist))
(define setup ggspec-acons)
(define run-test ggspec-acons)
(define (stub retval) (lambda args retval))
(define teardown cons)
(define end '())

(define (println . args) (for-each display args) (display #\newline))

(define (assert-equal expected got)
  (if (equal? expected got)
    #t
    (begin
      (println "      Expected: " expected)
      (println "           Got: " got)
      #f)))

(define (assert-not-equal not-expected got)
  (if (equal? not-expected got)
    (begin
      (println "      Expected: not " not-expected)
      (println "           Got: " got)
      #f)
    #t))

(define (assert-true x) (assert-equal #t (if x #t #f)))
(define (assert-false x) (assert-equal #f (if x #t #f)))

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

