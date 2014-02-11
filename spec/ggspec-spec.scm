#!
ggspec-spec - unit tests that verify the behaviour of ggspec.

Copyright (c) 2014 Yawar Amin
GitHub, Reddit, Twitter: yawaramin

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
!#
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

(suite "The range function"
  (tests
    (test "Should return an empty list if start greater than stop"
      e
      ((e 'assert-equal) end (range 1.1 1)))
    (test "Should return exactly the specified range"
      e
      ((e 'assert-equal) (e 'l) (range 0 10 1)))
    (test "Should by default return a range incremented by 1"
      e
      ((e 'assert-equal) (e 'l) (range 0 10)))
    (test
      "Should by default return a range starting at 0 and incremented by 1"
      e
      ((e 'assert-equal) (e 'l) (range 10)))
    (test
      "Should stop at or before stop argument value if any args not integers"
      e
      ((e 'assert-equal) (list 1.1 2.2 3.3) (range 1.1 4 1.1))))
  (options
    (option 'colour #t)) ; Reminder to myself to fix the failing test.
  (setups
    (setup 'l (list 0 1 2 3 4 5 6 7 8 9))))

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

