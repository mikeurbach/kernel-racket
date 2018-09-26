#lang br/quicklang

(provide + *)

(define-macro (top-level EXPR)
  #'(#%module-begin
     (for-each displayln (reverse (flatten EXPR)))))
(provide (rename-out [top-level #%module-begin]))

(define-macro (define-op OP)
  #'(define-macro-cases OP
      [(OP X) #'X]
      [(OP X XS (... ...))
       #'(list 'OP X (OP XS (... ...)))]))

(define-op +)
(define-op *)
