#lang racket

(require "../../src/machine/vm.rkt" rackunit)

(define namespace (module->namespace 'racket))

(define (run-vm insts)
  (define myvm (new vm [namespace namespace] [instructions insts]))
  (send myvm execute)
  myvm)

(define (assert-register myvm name value)
  (let ([register-value (send myvm vm-get-register-value name)])
    (check-equal? register-value value)))

(let ([myvm (run-vm '((assign (foo (const 420)))))])
  (assert-register myvm 'foo 420))

(let ([myvm (run-vm '((assign (foo (const 420)))
                      (assign (foo (const 69)))))])
  (assert-register myvm 'foo 69))

(let ([myvm (run-vm '((assign (foo (const 420)))
                      (assign (bar (reg foo)))))])
  (assert-register myvm 'foo 420)
  (assert-register myvm 'bar 420))

(let ([myvm (run-vm '((assign (foo (const 420)))
                      (assign (bar (const 69)))
                      (assign (baz (op +) (reg foo) (reg bar)))))])
  (assert-register myvm 'foo 420)
  (assert-register myvm 'bar 69)
  (assert-register myvm 'baz 489))

(let ([myvm (run-vm '((assign (val (const 1)))
                      (branch (#t done))
                      (assign (val (const 2)))
                      done))])
  (assert-register myvm 'val 1))

(let ([myvm (run-vm '((assign (val (const 1)))
                      loop
                      (assign (val (op +) (reg val) (const 1)))
                      (branch (((op <) (reg val) (const 10)) loop))))])
  (assert-register myvm 'val 10))

(let ([myvm (run-vm '((assign (val (const 1)))
                      loop
                      (assign (val (op +) (reg val) (const 1)))
                      (branch (((op eq?) (reg val) (const 5)) done)
                              (((op <) (reg val) (const 10)) loop))
                      done))])
  (assert-register myvm 'val 5))

(let ([myvm (run-vm '((assign (a (const 1)) (b (reg a)))))])
  (assert-register myvm 'a 1)
  (assert-register myvm 'b #f))

(let ([myvm (run-vm '((assign (a (const 420)) (b (const 69)))
                      (assign (a (reg b)) (b (reg a)))))])
  (assert-register myvm 'a 69)
  (assert-register myvm 'b 420))

;; GCD
(let ([myvm (new vm [namespace namespace] [instructions '(test-b
                                    (branch (((op eq?) (reg b) (const 0)) done))
                                    (assign (a (reg b))
                                            (b (op remainder) (reg a) (reg b)))
                                    (branch (#t test-b))
                                    done
                                    (assign (result (reg a))))])])
  (send myvm vm-set-register-value! 'a 24)
  (send myvm vm-set-register-value! 'b 9)
  (send myvm execute)
  (assert-register myvm 'result 3))

;; Fibonacci
(let ([myvm (new vm [namespace namespace] [instructions '((assign (prev (const 0))
                                            (curr (const 1)))
                                    test-n
                                    (branch (((op eq?) (reg n) (const 0)) done))
                                    (assign (curr (op +) (reg prev) (reg curr))
                                            (prev (reg curr))
                                            (n (op -) (reg n) (const 1)))
                                    (branch (#t test-n))
                                    done
                                    (assign (result (reg prev))))])])
  (send myvm vm-set-register-value! 'n 100)
  (send myvm execute)
  (assert-register myvm 'result 354224848179261915075))

;; Factorial
(let ([myvm (new vm [namespace namespace] [instructions '((assign (product (const 1)))
                                    test-n
                                    (branch (((op eq?) (reg n) (const 0)) done))
                                    (assign (product (op *) (reg n) (reg product))
                                            (n (op -) (reg n) (const 1)))
                                    (branch (#t test-n))
                                    done
                                    (assign (result (reg product))))])])
  (send myvm vm-set-register-value! 'n 5)
  (send myvm execute)
  (assert-register myvm 'result 120))
