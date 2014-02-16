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
      (assert-equal end (kwalist end)))
    (test
      "Should throw an error if it is given an odd number of args"
      e
      (assert-all
        (assert-true (error? (kwalist (list #:a))))
        (assert-true (error? (kwalist (list #:a 1 #:b))))
        (assert-true (error? (kwalist (list #:a 1 #:b 2 #:c))))
        (assert-true
          (error? (kwalist (list #:a 1 #:b 2 #:c 3 #:d))))))
    (test
      "Should not throw an error if it is given an even number of args"
      e
      (assert-all
        (assert-false (error? (kwalist (e 'l1))))
        (assert-false (error? (kwalist (e 'l2))))
        (assert-false (error? (kwalist (e 'l3))))
        (assert-false (error? (kwalist (e 'l4))))))
    (test
      "Should throw an error if odd-numbered args are not keywords"
      e
      (assert-all
        (assert-true (error? (kwalist '(1 2))))
        (assert-true (error? (kwalist '(#\a 2))))
        (assert-true (error? (kwalist '("a" 2))))
        (assert-true (error? (kwalist '((1) 2))))))
    (test
      "Should return an alist of symbols to values if given a list of keywords and values"
      e
      (assert-all
        (assert-equal (list (cons 'a 1)) (kwalist (e 'l1)))
        (assert-equal
          (list (cons 'a 1) (cons 'b 2))
          (kwalist (e 'l2)))
        (assert-equal
          (list (cons 'a 1) (cons 'b 2) (cons 'c 3))
          (kwalist (e 'l3)))
        (assert-equal
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
      (assert-equal end (range 1.1 1)))
    (test "Should return exactly the specified range"
      e
      (assert-equal (e 'l) (range 0 10 1)))
    (test "Should by default return a range incremented by 1"
      e
      (assert-equal (e 'l) (range 0 10)))
    (test
      "Should by default return a range starting at 0 and incremented by 1"
      e
      (assert-equal (e 'l) (range 10)))
    (test
      "Should stop at or before stop argument value if any args not integers"
      e
      (assert-equal (list 1.1 2.2 3.3) (range 1.1 4 1.1))
      (options
        (option 'skip #t))))
  (options
    (option 'colour #t)) ; Reminder to myself to fix the failing test.
  (setups
    (setup 'l (list 0 1 2 3 4 5 6 7 8 9))))

(suite "ggspec assertion functions"
  (tests
    (test "Should assert equality"
      e
      (assert-all
        (assert-equal 1 1)
        (assert-equal #\a #\a)
        (assert-equal "a" "a")))
    (test "Should assert an error if an error occurred"
      e
      (assert-true (error? (/ 1 0))))
    (test "Should not assert an error if an error did not occur"
      e
      (assert-false (error? (/ 1 1))))))

(suite "A ggspec example suite"
  (tests
    (test "Should have one each of passes, fails, and skips"
      e
      (begin
        (define results ((e 's)))
        (assert-all
          (assert-equal 1 (suite-passed results))
          (assert-equal 1 (suite-failed results))
          (assert-equal 1 (suite-skipped results)))))
    (test "The setup and teardown functions should be run before and after every test"
      e
      (assert-equal
        (string-append
          "Setup\n"
          "Teardown\n"
          "Setup\n"
          "Teardown\n")
        (with-output-to-string (e 's)))))
  (options)
  (setups
    (setup 's
      (lambda ()
        (suite "A test-internal suite"
          (tests
            (test "A passing test" e (assert-equal 1 1))
            (test "A failing test" e (assert-equal 0 1))
            (test "A skipped test"
              e
              (assert-equal 0 1)
              (options
                (option 'skip #t))))
          (options (option 'output-cb output-none))
          (setups (setup 's (println "Setup")))
          (teardowns (teardown e (println "Teardown"))))))))

(suite "The suite-add-option function"
  (tests
    (test "Should add an option to a suite with a description and tests only"
      e
      (assert-equal
        '(suite "Suite"
          (tests (test "Test" e (assert-true #t)))
          (options (option 'a 1)))
        (suite-add-option
          (e 'opt)
          '(suite "Suite"
            (tests (test "Test" e (assert-true #t)))))))
    (test "Should add an option to a suite with a description, tests, and options"
      e
      (assert-equal
        '(suite "Suite"
          (tests (test "Test" e (assert-true #t)))
          (options (option 'a 1) (option 'b 2)))
        (suite-add-option
          (e 'opt)
          '(suite "Suite"
            (tests (test "Test" e (assert-true #t)))
            (options (option 'b 2))))))
    (test "Should add an option to a suite with a description, tests, options, and setups"
      e
      (assert-equal
        '(suite "Suite"
          (tests (test "Test" e (assert-true #t)))
          (options (option 'a 1) (option 'b 2))
          (setups))
        (suite-add-option
          (e 'opt)
          '(suite "Suite"
            (tests (test "Test" e (assert-true #t)))
            (options (option 'b 2))
            (setups)))))
    (test "Should add an option to a suite with a description, tests, options, setups, and teardowns"
      e
      (assert-equal
        '(suite "Suite"
          (tests (test "Test" e (assert-true #t)))
          (options (option 'a 1) (option 'b 2))
          (setups)
          (teardowns))
        (suite-add-option
          (e 'opt)
          '(suite "Suite"
            (tests (test "Test" e (assert-true #t)))
            (options (option 'b 2))
            (setups)
            (teardowns)))))
    (test "Should not add an option if the suite already has that option"
      e
      (assert-equal
        '(suite "Suite"
          (tests (test "Test" e (assert-true #t)))
          (options (option 'a 0)))
        (suite-add-option
          (e 'opt)
          '(suite "Suite"
            (tests (test "Test" e (assert-true #t)))
            (options (option 'a 0)))))))
  (options)
  (setups (setup 'opt '(option 'a 1))))

(suite "The output functions"
  (tests
    (test "Should display normal diagnostics correctly"
      e
      (assert-equal
        (string-append
          "  Suite: internal\n"
          "    [SKIP] This should be skipped\n"
          "    [PASS]\n"
          "    [FAIL] 1 should equal 2\n"
          "      Expected: '2'\n"
          "           Got: '1'\n"
          "    [FAIL] 1 should not equal 1\n"
          "      Expected: not '1'\n"
          "           Got: '1'\n"
          "    [FAIL] true should be false\n"
          "      Expected: 'false'\n"
          "           Got: 'true'\n"
          "    [FAIL] 1/0 should not be an error\n"
          "      Expected: 'false'\n"
          "           Got: 'true'\n"
          "\n")
        (with-output-to-string
          (lambda () (eval (e 's) (current-module))))))
    (test "Should display TAP diagnostics correctly"
      e
      (assert-equal
        (string-append
          "# Suite: internal\n"
          "ok - This should be skipped # SKIP\n"
          "ok - This should pass\n"
          "not ok - 1 should equal 2\n"
          "# Expected: '2'\n"
          "#      Got: '1'\n"
          "not ok - 1 should not equal 1\n"
          "# Expected: not '1'\n"
          "#      Got: '1'\n"
          "not ok - true should be false\n"
          "# Expected: 'false'\n"
          "#      Got: 'true'\n"
          "not ok - 1/0 should not be an error\n"
          "# Expected: 'false'\n"
          "#      Got: 'true'\n"
          "1..6\n")
        (with-output-to-string
          (lambda ()
            (eval
              (suite-add-option
                '(option 'output-cb output-tap)
                (e 's))
              (current-module)))))))
  (options)
  (setups
    (setup 's
      '(suite "internal"
        (tests
          (test "This should pass" e (assert-equal 1 1))
          (test "This should be skipped"
            e
            (assert-equal 2 1)
            (options
              (option 'skip #t)))
          (test "1 should equal 2" e (assert-equal 2 1))
          (test "1 should not equal 1" e (assert-not-equal 1 1))
          (test "true should be false" e (assert-false #t))
          (test "1/0 should not be an error"
            e
            (assert-false (error? (/ 1 0)))))
        (options (option 'tally #t))))))

(suite "The run-file function"
  (tests
    (test "Should report results for a file with test suites"
      e
      (assert-equal
        (list 1 1 1)
        (stub
          '(ggspec lib)
          'call-with-input-file
          (lambda (fname proc)
            (call-with-input-string
              (string-append
                "(suite \"1\"\n"
                "  (tests\n"
                "    (test \"A\" e (assert-true #t))\n"
                "    (test \"B\" e (assert-true #f))\n"
                "    (test \"A\"\n"
                "      e\n"
                "      (assert-true #t)\n"
                "      (options (option 'skip #t))))\n"
                "  (options (option 'output-cb output-none)))\n"
                "\n"
                "(suite \"2\"\n"
                "  end\n"
                "  (options (option 'output-cb output-none)))\n")
              proc))
          (run-file "test-file" end))))))

