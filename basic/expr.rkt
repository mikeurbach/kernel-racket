#lang br

(require "line.rkt")
(provide b-sum b-product b-neg b-expt b-expr b-def b-func)

(define-macro-cases b-sum
  [(_ VAL) #'VAL]
  [(_ LEFT "+" RIGHT) #'(+ LEFT RIGHT)]
  [(_ LEFT "-" RIGHT) #'(- LEFT RIGHT)])

(define-macro-cases b-product
  [(_ VAL) #'VAL]
  [(_ LEFT "*" RIGHT) #'(* LEFT RIGHT)]
  [(_ LEFT "/" RIGHT) #'(/ LEFT RIGHT 1.0)]
  [(_ LEFT "mod" RIGHT) #'(modulo LEFT RIGHT)])

(define-macro-cases b-neg
  [(_ VAL) #'VAL]
  [(_ "-" VAL) #'(- VAL)])

(define-macro-cases b-expt
  [(_ VAL) #'VAL]
  [(_ LEFT "^" RIGHT) #'(expt LEFT RIGHT)])

(define (b-expr expr)
  (if (integer? expr) (inexact->exact expr) expr))

(define-macro (b-def FUNC-ID VAR-ID ... EXPR)
  (syntax-local-lift-expression
   #'(set! FUNC-ID (lambda (VAR-ID ...) EXPR))))

(define-macro (b-func FUNC-ID ARG ...)
  #'(if (procedure? FUNC-ID)
        (convert-result (FUNC-ID ARG ...))
        (raise-line-err
         (format "expected ~a to be a function, got ~v" 'FUNC-ID FUNC-ID))))

(define (convert-result result)
  (cond
    [(number? result) (b-expr result)]
    [(string? result) result]
    [(boolean? result) (if result 1 0)]
    [else
     (raise-line-err
      (format "unknown data type ~v" result))]))
