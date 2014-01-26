(use-modules (my ggspec))

(run-suite "run-suite"
  (setup 'one (lambda () 1)
  (setup 'two (lambda () 2)
  (setup 'stra (lambda () "a")
  (setup 'strb (lambda () "b")
  (setup 'chara (lambda () #\a)
  (setup 'charb (lambda () #\b)
  end))))))

  (run-test "Should assert equality correctly"
    (lambda (e)
      (and
        (assert-equal (e 'one) (e 'one))
        (assert-equal (e 'stra) (e 'stra))
        (assert-equal (e 'chara) (e 'chara))
        (assert-equal '((e 'one)) '((e 'one)))))
  (run-test "Should assert inequality correctly"
    (lambda (e)
      (and
        (assert-not-equal (e 'one) (e 'two))
        (assert-not-equal (e 'stra) (e 'strb))
        (assert-not-equal (e 'chara) (e 'charb))
        (assert-not-equal '((e 'one)) '((e 'two)))))
  (run-test "Should assert truthiness correctly"
    (lambda (e)
      (and
        (assert-true (= (e 'one) (e 'one)))
        (assert-true (string=? (e 'stra) (e 'stra)))
        (assert-true 0)
        (assert-true '())
        (not (assert-true (= (e 'one) (e 'two))))
        (not (assert-true (string=? (e 'stra) (e 'strb))))
        (not (assert-true #f))))
  (run-test "Should assert falsiness correctly"
    (lambda (e)
      (and
        (assert-false #f)
        (assert-false (= (e 'one) (e 'two)))
        (assert-false (string=? (e 'stra) (e 'strb)))
        (not (assert-false (= (e 'one) (e 'one))))
        (not (assert-false (string=? (e 'stra) (e 'stra))))
        (not (assert-false 0))
        (not (assert-false '()))))
  (run-test "Should have set up 'environment' of one == 1"
    (lambda (e) (assert-equal 1 (e 'one)))
  end)))))

  end)

