#lang racket

(require "boolean.rkt" "evaluator.rkt")

(provide inert? kernel-if)

(define (inert? object)
  (eqv? object '|#inert|))

(define (kernel-if ptree env)
  (letrec ([predicate (mcar ptree)]
           [consequent (mcar (mcdr ptree))]
           [alternative (mcar (mcdr (mcdr ptree)))]
           [result (kernel-eval predicate env)])
    (cond [(eqv? result #t) (kernel-eval consequent env)]
          [(eqv? result #f) (kernel-eval alternative env)]
          [#t (raise-argument-error '$if "boolean?" result)])))
