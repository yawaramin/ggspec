;; ggspec - lightweight unit testing library for Guile
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(use-modules (my ggspec))

(define test-assertions
  (suite "ggspec assertion functions"
    (tests
      (test "Should assert equality"
        (lambda (e)
          (and
            ((e 'assert-equal) 1 1)
            ((e 'assert-equal) #\a #\a)
            ((e 'assert-equal) "a" "a"))))
      (test "Should assert an error if an error occurred"
        (lambda (e) ((e 'assert-error) (lambda () (/ 1 0)))))
      (test "Should not assert an error if an error did not occur"
        (lambda (e) (not ((e 'assert-error) (lambda () (/ 1 1))))))
      (test "Should assert an error did not occur if it did not"
        (lambda (e) ((e 'assert-not-error) (lambda () (/ 1 1)))))
      (test "Should not assert an error did not occur if it did"
        (lambda (e)
          (not ((e 'assert-not-error) (lambda () (/ 1 0)))))))))

(define test-suite
  (suite "A ggspec example suite"
    (tests
      (test "Should have one pass and one fail"
        (lambda (e)
          (and
            ((e 'assert-equal) 1 (length (suite-passes ((e 's)))))
            ((e 'assert-equal) 1 (length (suite-fails ((e 's))))))))
      (test "Should make its creation arguments available"
        (lambda (e)
          (define args (suite-args))
          (and
            ((e 'assert-equal) "A test-internal suite" (car args))
            ((e 'assert-equal) end (caddr args))
            ((e 'assert-equal) end (list-ref args 4)))))
      (test "Should name the passing test"
        (lambda (e)
          ((e 'assert-equal)
            "A passing test"
            (car (suite-passes ((e 's)))))))
      (test "Should name the failing test"
        (lambda (e)
          ((e 'assert-equal)
            "A failing test"
            (car (suite-fails ((e 's))))))))
    (options)
    (setups
      (setup 's
        (lambda ()
          (suite "A test-internal suite"
            (tests
              (test "A passing test" (lambda (e) #t))
              (test "A failing test" (lambda (e) #f)))
            (options
              (option 'output-cb none))))))))

(test-assertions)
(test-suite)

