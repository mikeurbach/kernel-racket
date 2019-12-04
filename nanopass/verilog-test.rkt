#lang nanopass

(require "verilog.rkt")

(define-parser verilog-parser verilog)

;; Basic Assigns

;;;; Register Target, Register Value

(output-verilog
 (verilog-parser
  '((reg foo) (reg bar))))

(output-verilog
 (verilog-parser
  '((reg foo) (reg bar (7 . 0)))))

(output-verilog
 (verilog-parser
  '((reg foo (7 . 0)) (reg bar))))

(output-verilog
 (verilog-parser
  '((reg foo (7 . 0)) (reg bar (7 . 0)))))

;;;; Register Target, Memory Value

(output-verilog
 (verilog-parser
  '((reg foo) (mem ram (reg addr)))))

(output-verilog
 (verilog-parser
  '((reg foo) (mem ram (reg addr (7 . 0))))))

(output-verilog
 (verilog-parser
  '((reg foo (7 . 0)) (mem ram (reg addr)))))

(output-verilog
 (verilog-parser
  '((reg foo (7 . 0)) (mem ram (reg addr (7 . 0))))))

;;;; Register Target, Input Value

(output-verilog
 (verilog-parser
  '((reg foo) (in bar))))

(output-verilog
 (verilog-parser
  '((reg foo) (in bar (7 . 0)))))

(output-verilog
 (verilog-parser
  '((reg foo (7 . 0)) (in bar))))

(output-verilog
 (verilog-parser
  '((reg foo (7 . 0)) (in bar (7 . 0)))))

;;;; Memory Target, Register Value

(output-verilog
 (verilog-parser
  '((mem ram (reg foo)) (reg bar))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo)) (reg bar (7 . 0)))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo (7 . 0))) (reg bar))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo (7 . 0))) (reg bar (7 . 0)))))

(output-verilog
 (verilog-parser
  '((mem ram (const 8 d 23)) (reg bar))))

;;;; Memory Target, Memory Value

(output-verilog
 (verilog-parser
  '((mem ram (reg foo)) (mem ram (reg addr)))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo)) (mem ram (reg addr (7 . 0))))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo (7 . 0))) (mem ram (reg addr)))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo (7 . 0))) (mem ram (reg addr (7 . 0))))))

;;;; Memory Target, Input Value

(output-verilog
 (verilog-parser
  '((mem ram (reg foo)) (in bar))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo)) (in bar (7 . 0)))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo (7 . 0))) (in bar))))

(output-verilog
 (verilog-parser
  '((mem ram (reg foo (7 . 0))) (in bar (7 . 0)))))

;;;; Output Target, Register Value

(output-verilog
 (verilog-parser
  '((out foo) (reg bar))))

(output-verilog
 (verilog-parser
  '((out foo) (reg bar (7 . 0)))))

(output-verilog
 (verilog-parser
  '((out foo (7 . 0)) (reg bar))))

(output-verilog
 (verilog-parser
  '((out foo (7 . 0)) (reg bar (7 . 0)))))

;;;; Output Target, Memory Value

(output-verilog
 (verilog-parser
  '((out foo) (mem ram (reg addr)))))

(output-verilog
 (verilog-parser
  '((out foo) (mem ram (reg addr (7 . 0))))))

(output-verilog
 (verilog-parser
  '((out foo (7 . 0)) (mem ram (reg addr)))))

(output-verilog
 (verilog-parser
  '((out foo (7 . 0)) (mem ram (reg addr (7 . 0))))))

;;;; Output Target, Input Value

(output-verilog
 (verilog-parser
  '((out foo) (in bar))))

(output-verilog
 (verilog-parser
  '((out foo) (in bar (7 . 0)))))

(output-verilog
 (verilog-parser
  '((out foo (7 . 0)) (in bar))))

(output-verilog
 (verilog-parser
  '((out foo (7 . 0)) (in bar (7 . 0)))))

;; Unary Operator Assigns

(output-verilog
 (verilog-parser
  '((reg foo) (op -) (reg bar))))

(output-verilog
 (verilog-parser
  '((reg foo) (op ~) (reg bar))))

;; Binary Operator Assigns

(output-verilog
 (verilog-parser
  '((reg foo) (reg bar) (op +) (reg baz))))

(output-verilog
 (verilog-parser
  '((reg foo) (reg bar) (op +) (const 8 d 1))))

(output-verilog
 (verilog-parser
  '((reg foo) (reg bar) (op &) (reg baz))))

(output-verilog
 (verilog-parser
  '((reg foo) (reg bar) (op &) (const 8 h ff))))

(output-verilog
 (verilog-parser
  '((reg foo) (reg bar) (op \|) (const 8 b 11110000))))

;; Next State

(output-verilog
 (verilog-parser
  'init))

(output-verilog
 (verilog-parser
  '(case (in start)
     ((const 1 b 1) opcase)
     init)))

(output-verilog
 (verilog-parser
  '(case (in op)
     ((const 2 d 0) op1)
     ((const 2 d 1) op2)
     init)))