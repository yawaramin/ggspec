(use-modules (my ggspec))

(define (test-assertions)
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

(define (test-suite)
  (suite "A ggspec example suite"
    (options
      (option 'output-cb text-verbose))
    (setups
      (setup 's
        (lambda ()
          (suite "A test-internal suite"
            (options
              (option 'output-cb none))
            (setups)
            (tests
              (test "A passing test" (options) (lambda (e) #t))
              (test "A failing test" (options) (lambda (e) #f)))))))
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

