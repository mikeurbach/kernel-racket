#lang nanopass

(require "verilog.rkt")

(define-parser verilog-parser verilog)

;; Primitives

;;;; Registers

(output-verilog
 (verilog-parser
  '(reg foo)))

(output-verilog
 (verilog-parser
  '(reg foo (7 . 0))))

;;;; Inputs

(output-verilog
 (verilog-parser
  '(in foo)))

(output-verilog
 (verilog-parser
  '(in foo (7 . 0))))

;;;; Outputs

(output-verilog
 (verilog-parser
  '(out foo)))

(output-verilog
 (verilog-parser
  '(out foo (7 . 0))))

;;;; Memories

(output-verilog
 (verilog-parser
  '(mem cars (reg next-reg))))

(output-verilog
 (verilog-parser
  '(mem cars (reg next-reg (7 . 0)))))

(output-verilog
 (verilog-parser
  '(mem cars (in car))))

(output-verilog
 (verilog-parser
  '(mem cars (in car (7 . 0)))))
