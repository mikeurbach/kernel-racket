#lang racket

(require "../../src/machine/vm.rkt" "../../src/machine/register.rkt" rackunit)

(define (run-vm insts)
  (define myvm (new vm [instructions insts]))
  (send myvm execute)
  myvm)

(define (assert-register myvm name value)
  (let ([register (send myvm get-register name)])
    (check-eq? (register-value register) value)))

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
