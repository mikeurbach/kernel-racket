#lang racket

(require "../../src/machine/vm.rkt" rackunit)

'((assign (foo (const 420))))

'((assign (foo (const 420)))
  (assign (foo (const 69))))

'((assign (foo (const 420)))
  (assign (bar (reg foo))))

'((assign (foo (const 420)))
  (assign (bar (const 69)))
  (assign (baz (op +) (reg foo) (reg bar))))

'((assign (val (const 1)))
  (branch (#t done))
  (assign (val (const 2)))
  done)

'((assign (val (const 1)))
  loop
  (assign (val (op +) (reg val) (const 1)))
  (branch (((op <) (reg val) (const 10)) loop)))

'((assign (val (const 1)))
  loop
  (assign (val (op +) (reg val) (const 1)))
  (branch (((op eq?) (reg val) (const 5)) done)
          (((op <) (reg val) (const 10)) loop))
  done)

;; a should be 1, but b should be #f since the assign happens concurrently
'((assign (a (const 1))
          (b (reg a))))
