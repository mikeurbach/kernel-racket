#lang nanopass

(require "verilog.rkt")

(define-parser verilog-parser verilog)

;; Basic Assigns

;;;; Register Target, Register Value

(output-verilog
 (verilog-parser
  '((((reg foo) (reg bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo) (reg bar (7 . 0))))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo (7 . 0)) (reg bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo (7 . 0)) (reg bar (7 . 0))))
    init)))

;;;; Register Target, Memory Value

(output-verilog
 (verilog-parser
  '((((reg foo) (mem ram (reg addr))))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo) (mem ram (reg addr (7 . 0)))))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo (7 . 0)) (mem ram (reg addr))))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo (7 . 0)) (mem ram (reg addr (7 . 0)))))
    init)))

;;;; Register Target, Input Value

(output-verilog
 (verilog-parser
  '((((reg foo) (in bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo) (in bar (7 . 0))))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo (7 . 0)) (in bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo (7 . 0)) (in bar (7 . 0))))
    init)))

;;;; Memory Target, Register Value

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo)) (reg bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo)) (reg bar (7 . 0))))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo (7 . 0))) (reg bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo (7 . 0))) (reg bar (7 . 0))))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (const 8 d 23)) (reg bar)))
    init)))

;;;; Memory Target, Memory Value

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo)) (mem ram (reg addr))))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo)) (mem ram (reg addr (7 . 0)))))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo (7 . 0))) (mem ram (reg addr))))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo (7 . 0))) (mem ram (reg addr (7 . 0)))))
    init)))

;;;; Memory Target, Input Value

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo)) (in bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo)) (in bar (7 . 0))))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo (7 . 0))) (in bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((mem ram (reg foo (7 . 0))) (in bar (7 . 0))))
    init)))

;;;; Output Target, Register Value

(output-verilog
 (verilog-parser
  '((((out foo) (reg bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo) (reg bar (7 . 0))))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo (7 . 0)) (reg bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo (7 . 0)) (reg bar (7 . 0))))
    init)))

;;;; Output Target, Memory Value

(output-verilog
 (verilog-parser
  '((((out foo) (mem ram (reg addr))))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo) (mem ram (reg addr (7 . 0)))))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo (7 . 0)) (mem ram (reg addr))))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo (7 . 0)) (mem ram (reg addr (7 . 0)))))
    init)))

;;;; Output Target, Input Value

(output-verilog
 (verilog-parser
  '((((out foo) (in bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo) (in bar (7 . 0))))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo (7 . 0)) (in bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((out foo (7 . 0)) (in bar (7 . 0))))
    init)))

;; Unary Operator Assigns

(output-verilog
 (verilog-parser
  '((((reg foo) (op -) (reg bar)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo) (op ~) (reg bar)))
    init)))

;; Binary Operator Assigns

(output-verilog
 (verilog-parser
  '((((reg foo) (reg bar) (op +) (reg baz)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo) (reg bar) (op +) (const 8 d 1)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo) (reg bar) (op &) (reg baz)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo) (reg bar) (op &) (const 8 h ff)))
    init)))

(output-verilog
 (verilog-parser
  '((((reg foo) (reg bar) (op \|) (const 8 b 11110000)))
    init)))

;; Next State

(output-verilog
 (verilog-parser
  '(()
    init)))

(output-verilog
 (verilog-parser
  '(()
    (case (in start)
      ((const 1 b 1) opcase)
      init))))

(output-verilog
 (verilog-parser
  '(()
    (case (in op)
      ((const 2 d 0) op1)
      ((const 2 d 1) op2)
      init))))
