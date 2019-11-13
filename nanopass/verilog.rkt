#lang nanopass

(require "module-printer.rkt")

(define-language module-specification
  (terminals
   (identifier (identifier))
   (symbol (symbol))
   (port-type (port-type))
   (size (size)))
  (Expr (e)
        symbol
        (mod identifier (e0 ...) (e1 ...))
        (input identifier size)
        (output identifier size)))

(define identifier? string?)
(define port-type? string?)
(define (size? e)
  (or
   (empty? e)
   (and
    (pair? e)
    (number? (car e))
    (number? (cdr e)))))

(define-pass output-module : module-specification (ast) -> * ()
  (definitions
    (define (module-writer name operations ports)
      (new module-printer
           [operations operations]
           [name name]
           [ports ports])))
  (pass : Expr (e) -> * ()
        [,symbol symbol]
        [(mod ,identifier
              (,[pass : operations] ...)
              (,[pass : ports] ...))
         (display
          (send (module-writer
                 identifier
                 operations
                 ports) print))]
        [(input ,identifier ,size) (list 'input identifier size)]
        [(output ,identifier ,size) (list 'output identifier size)]))

(begin
  (define-parser mod-parser module-specification)
  (output-module
   (mod-parser
    '(mod "pair"
          (new car cdr set_car set_cdr)
          ((input "car" (8 . 0))
           (input "cdr" (8 . 0))
           (input "ref_in" (8 . 0))
           (output "ref_out" (8 . 0)))))))
