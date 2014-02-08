;; ggspec - lightweight unit testing library for Guile
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin
(use-modules (my ggspec))

(define test-kwalist
  (suite "The kwalist function"
    (tests
      (test "Should return an empty list if it is given an empty list"
        (lambda (e)
          ((e 'assert-equal) end (kwalist end))))
      (test
        "Should throw an error if it is given an odd number of args"
        (lambda (e)
          (and
            ((e 'assert-error) (lambda () (kwalist (list #:a))))
            ((e 'assert-error) (lambda () (kwalist (list #:a 1 #:b))))
            ((e 'assert-error)
              (lambda () (kwalist (list #:a 1 #:b 2 #:c))))
            ((e 'assert-error)
              (lambda () (kwalist (list #:a 1 #:b 2 #:c 3 #:d)))))))
      (test
        "Should not throw an error if it is given an even number of args"
        (lambda (e)
          (and
            ((e 'assert-not-error) (lambda () (kwalist (e 'l1))))
            ((e 'assert-not-error) (lambda () (kwalist (e 'l2))))
            ((e 'assert-not-error) (lambda () (kwalist (e 'l3))))
            ((e 'assert-not-error) (lambda () (kwalist (e 'l4)))))))
      (test
        "Should throw an error if odd-numbered args are not keywords"
        (lambda (e)
          (and
            ((e 'assert-error) (lambda () (kwalist '(1 2))))
            ((e 'assert-error) (lambda () (kwalist '(#\a 2))))
            ((e 'assert-error) (lambda () (kwalist '("a" 2))))
            ((e 'assert-error) (lambda () (kwalist '((1) 2)))))))
      (test
        "Should return an alist of symbols to values if given a list of keywords and values"
        (lambda (e)
          (and
            ((e 'assert-equal) (list (cons 'a 1)) (kwalist (e 'l1)))
            ((e 'assert-equal)
              (list (cons 'a 1) (cons 'b 2))
              (kwalist (e 'l2)))
            ((e 'assert-equal)
              (list (cons 'a 1) (cons 'b 2) (cons 'c 3))
              (kwalist (e 'l3)))
            ((e 'assert-equal)
              (list (cons 'a 1) (cons 'b 2) (cons 'c 3) (cons 'd 4))
              (kwalist (e 'l4)))))))
    (options)
    (setups
      (setup 'l1 (lambda () (list #:a 1)))
      (setup 'l2 (lambda () (list #:a 1 #:b 2)))
      (setup 'l3 (lambda () (list #:a 1 #:b 2 #:c 3)))
      (setup 'l4 (lambda () (list #:a 1 #:b 2 #:c 3 #:d 4))))))

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
          (define results (e 's))
          (and
            ((e 'assert-equal) 1 (car results))
            ((e 'assert-equal) 1 (cadr results)))))
      (test "Should make its creation arguments available"
        (lambda (e)
          (define args (suite-args))
          (and
            ((e 'assert-equal) "A test-internal suite" (car args))
            ((e 'assert-equal) end (caddr args))
            ((e 'assert-equal) end (list-ref args 4))))))
    (options)
    (setups
      (setup 's
        (lambda ()
          ((suite "A test-internal suite"
            (tests
              (test "A passing test" (lambda (e) #t))
              (test "A failing test" (lambda (e) #f)))
            (options
              (option 'output-cb none)))))))))

(test-kwalist)
(test-assertions)
(test-suite)

