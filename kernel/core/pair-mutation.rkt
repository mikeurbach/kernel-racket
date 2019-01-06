#lang racket

(require (except-in "pair.rkt" cons))

(provide set-car! set-cdr! copy-es-immutable)

(define (set-car! object value)
  (set-mcar! object value))

(define (set-cdr! object value)
  (set-mcdr! object value))

; this was an exercise for the reader. the evaluator only works with mutable pairs.
(define (copy-es-immutable object)
  (if (not (pair? object))
      object
      (let ([new-car (copy-es-immutable (mcar object))]
            [new-cdr (copy-es-immutable (mcdr object))])
        (cons new-car new-cdr))))
