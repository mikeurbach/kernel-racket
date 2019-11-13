#lang racket

(require "verilog-printer.rkt")

(provide port-printer)

(define port-printer
  (class base-verilog-printer%
    (super-new)
    (init-field port)
    (define/override (do-print)
      (let ([type (car port)]
            [name (cadr port)]
            [size (caddr port)])
        (string-join (list (type-string type) (size-string size) name) " ")))))

(define (type-string type)
  (cond [(eq? type 'input) "input"]
        [(eq? type 'output) "output reg"]))

(define (size-string size)
  (if (empty? size)
      ""
      (let ([top (number->string (car size))]
            [bottom (number->string (cdr size))])
        (string-append "[" top ":" bottom "]"))))
