;; ggspec - lightweight unit testing library for GNU Guile (and other
;; Schemes?)
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(use-modules (my ggspec))

(define test-assertions
  (suite "ggspec assertion functions"
    (tests
      (test "Should assert equality"
        (options)
        (lambda (e)
          (and
            ((e 'assert-equal) 1 1)
            ((e 'assert-equal) #\a #\a)
            ((e 'assert-equal) "a" "a")))))
    (options (option 'output-cb text-verbose))))

(define test-suite
  (suite "A ggspec example suite"
    (tests
      (test "Should have one pass and one fail"
        (options)
        (lambda (e)
          (and
            ((e 'assert-equal) 1 (length (suite-passes ((e 's)))))
            ((e 'assert-equal) 1 (length (suite-fails ((e 's))))))))
      (test "Should make its creation arguments available"
        (options)
        (lambda (e)
          (define args (suite-args))
          (and
            ((e 'assert-equal) "A test-internal suite" (car args))
            ((e 'assert-equal) end (caddr args))
            ((e 'assert-equal) end (list-ref args 4)))))
      (test "Should name the passing test"
        (options)
        (lambda (e)
          ((e 'assert-equal)
            "A passing test"
            (car (suite-passes ((e 's)))))))
      (test "Should name the failing test"
        (options)
        (lambda (e)
          ((e 'assert-equal)
            "A failing test"
            (car (suite-fails ((e 's))))))))
    (options (option 'output-cb text-verbose))
    (setups
      (setup 's
        (lambda ()
          (suite "A test-internal suite"
            (tests
              (test "A passing test" (options) (lambda (e) #t))
              (test "A failing test" (options) (lambda (e) #f)))
            (options
              (option 'output-cb none))
            (setups)))))))

(test-assertions)
(test-suite)

