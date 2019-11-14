#lang racket

(require "verilog-printer.rkt")

(provide operation-name-printer)

(define operation-name-printer
  (class base-verilog-printer%
    (super-new)
    (init-field operations)

    (define operation-params
      (let ([i -1])
        (map
         (lambda (op)
           (set! i (+ 1 i))
           (string-append
            "  localparam op_"
            (symbol->string op)
            " = "
            (number->string i)
            ";"))
         operations)))

    (define/override (do-print)
      (string-join operation-params "\n"))))
