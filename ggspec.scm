;; ggspec - lightweight unit testing library for GNU Guile (and other
;; Schemes?)
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(define-module (my ggspec)
  #:export
    (assert-equal
    assert-not-equal
    assert-true
    end
    run-suite
    run-test
    setup))

(define (ggspec-acons k v alist) (cons (cons k v) alist))
(define setup ggspec-acons)
(define run-test ggspec-acons)
(define end '())

(define (println . args)
  (for-each display args)
  (display #\newline))

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

(define (assert-true x)
  (assert-equal #t x))

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
            result))
        (or test-specs end)))
    (total (length results))
    (successes (length (filter identity results)))
    (failures (- total successes)))
    (println "  " total " test(s), " failures " failure(s).")))

;; The following is an example test suite to demonstrate the
;; functionality; it is _not_ a test suite over the unit testing
;; framework!
(define (main)
  (run-suite "Demonstration test suite"
    ;; Setup specs.
    (setup 'a (lambda () 1)
    (setup 'b (lambda () 2)
    end))
  
    ;; Test specs.
    (run-test "1 should equal 2 minus 1."
      (lambda (e) (assert-equal (e 'a) (- (e 'b) (e 'a))))
    (run-test "1 should not equal 4."
      (lambda (e) (assert-equal (e 'a) (+ (e 'b) (e 'b))))
    end))
  
    ;; Teardown functions
    end))

