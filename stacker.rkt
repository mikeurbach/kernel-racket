#lang br/quicklang

(provide + *)

(define (read-syntax path port)
  (define src-lines (port->lines port))
  (define src-datums (format-datums '(handle ~a) src-lines))
  (define module-datum `(module stacker-mod "stacker.rkt" ,@src-datums))
  (datum->syntax #f module-datum))
(provide read-syntax)

(define-macro (stacker-module-begin EXPR ...)
  #'(#%module-begin
     EXPR ...
     (display (first stack))))
(provide (rename-out [stacker-module-begin #%module-begin]))

(define stack empty)

(define (push! input)
  (set! stack (cons input stack)))

(define (pop!)
  (define head (first stack))
  (set! stack (rest stack))
  head)

; supports commutative operations on numbers
(define (handle [input #f])
  (cond [(number? input) (push! input)]
        [(or (equal? input +) (equal? input *))
         (define result (input (pop!) (pop!)))
         (push! result)]))
(provide handle)
