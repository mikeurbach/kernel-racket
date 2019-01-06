#lang racket

(require "boolean.rkt" "evaluator.rkt")

(provide kernel-inert? kernel-if)

(define (kernel-inert? object)
  (eqv? object '|#inert|))

(define (kernel-if args env)
  (letrec ([predicate (car args)]
           [consequent (cadr args)]
           [alternative (caddr args)]
           [result (kernel-eval predicate env)])
    (cond [(eqv? result #t) (kernel-eval consequent env)]
          [(eqv? result #f) (kernel-eval alternative env)]
          [#t (raise-argument-error '$if "boolean?" result)])))
