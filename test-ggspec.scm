;; ggspec - lightweight unit testing library for GNU Guile (and other
;; Schemes?)
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(use-modules (my ggspec))

(define test-assertions
  (suite "ggspec assertion functions"
    (options)
    (setups)
    (tests
      (test "Should assert equality"
        (options)
        (lambda (e)
          (and
            ((e 'assert-equal) 1 1)
            ((e 'assert-equal) #\a #\a)
            ((e 'assert-equal) "a" "a")))))
    (teardowns)))

(define test-suite
  (suite "A ggspec example suite"
    (options)
    (setups
      (setup 's
        (suite "A test-internal suite"
          (options
            (option 'output-cb none))
          (setups)
          (tests
            (test "A passing test" (options) (lambda (e) #t))
            (test "A failing test" (options) (lambda (e) #f)))
          (teardowns))))
    (tests
      (test "Should have one pass and one fail"
        (options)
        (lambda (e)
          (and
            ((e 'assert-equal) 1 (length (suite-passes (e 's))))
            ((e 'assert-equal) 1 (length (suite-fails (e 's)))))))
      (test "Should name the passing test"
        (options)
        (lambda (e)
          ((e 'assert-equal)
            "A passing test"
            (car (suite-passes (e 's))))))
      (test "Should name the failing test"
        (options)
        (lambda (e)
          ((e 'assert-equal)
            "A failing test"
            (car (suite-fails (e 's)))))))
    (teardowns)))

(test-assertions)
(test-suite)

