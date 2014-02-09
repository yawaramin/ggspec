;; ggspec - lightweight unit testing library for Guile
;; Copyright (c) 2014 Yawar Amin
;; See LICENSE file for details
;; GitHub, Reddit, Twitter: yawaramin

(suite "The kwalist function"
  (tests
    (test "Should return an empty list if it is given an empty list"
      e
      ((e 'assert-equal) end (kwalist end)))
    (test
      "Should throw an error if it is given an odd number of args"
      e
      (and
        ((e 'assert-true) (error? (kwalist (list #:a))))
        ((e 'assert-true) (error? (kwalist (list #:a 1 #:b))))
        ((e 'assert-true) (error? (kwalist (list #:a 1 #:b 2 #:c))))
        ((e 'assert-true)
          (error? (kwalist (list #:a 1 #:b 2 #:c 3 #:d))))))
    (test
      "Should not throw an error if it is given an even number of args"
      e
      (and
        ((e 'assert-false) (error? (kwalist (e 'l1))))
        ((e 'assert-false) (error? (kwalist (e 'l2))))
        ((e 'assert-false) (error? (kwalist (e 'l3))))
        ((e 'assert-false) (error? (kwalist (e 'l4))))))
    (test
      "Should throw an error if odd-numbered args are not keywords"
      e
      (and
        ((e 'assert-true) (error? (kwalist '(1 2))))
        ((e 'assert-true) (error? (kwalist '(#\a 2))))
        ((e 'assert-true) (error? (kwalist '("a" 2))))
        ((e 'assert-true) (error? (kwalist '((1) 2))))))
    (test
      "Should return an alist of symbols to values if given a list of keywords and values"
      e
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
          (kwalist (e 'l4))))))
  (options)
  (setups
    (setup 'l1 (list #:a 1))
    (setup 'l2 (list #:a 1 #:b 2))
    (setup 'l3 (list #:a 1 #:b 2 #:c 3))
    (setup 'l4 (list #:a 1 #:b 2 #:c 3 #:d 4))))

(suite "ggspec assertion functions"
  (tests
    (test "Should assert equality"
      e
      (and
        ((e 'assert-equal) 1 1)
        ((e 'assert-equal) #\a #\a)
        ((e 'assert-equal) "a" "a")))
    (test "Should assert an error if an error occurred"
      e
      ((e 'assert-true) (error? (/ 1 0))))
    (test "Should not assert an error if an error did not occur"
      e
      ((e 'assert-false) (error? (/ 1 1))))))

(suite "A ggspec example suite"
  (tests
    (test "Should have one pass and one fail"
      e
      (define results (e 's))
      (and
        ((e 'assert-equal) 1 (car results))
        ((e 'assert-equal) 1 (cadr results)))))
  (options)
  (setups
    (setup 's
      (suite "A test-internal suite"
        (tests
          (test "A passing test" e ((e 'assert-equal) 1 1))
          (test "A failing test" e ((e 'assert-equal) 0 1)))
        (options
          (option 'output-cb none))))))

