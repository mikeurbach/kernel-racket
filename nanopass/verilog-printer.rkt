#lang racket

(provide verilog-printer<%> base-verilog-printer%)

(define verilog-printer<%>
  (interface ()
    (print (->m string?))))

(define base-verilog-printer%
  (class* object% (verilog-printer<%>)
    (super-new)
    (abstract do-print)
    (define (before-hook) "")
    (define (after-hook) "")
    (define/pubment (print)
      (string-append
       (before-hook)
       (do-print)
       (after-hook)))))
