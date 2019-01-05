#lang racket

(require "boolean.rkt")

(provide inert? $if)

(define (inert? object)
  (eqv? object '|#inert|))

(define ($if predicate consequent alternative)
  (let ([result (eval predicate)])
    (if (not (boolean? result))
        (raise-argument-error '$if "boolean?" result)
        (if result
            (eval consequent)
            (eval alternative)))))
