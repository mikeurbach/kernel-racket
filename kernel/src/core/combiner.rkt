#lang racket

(provide make-operative operative? operative-proc operate
         make-applicative applicative? kernel-wrap kernel-unwrap)

(struct operative (proc))
(struct applicative (proc))

(define (make-operative proc)
  (operative proc))

(define (operate combiner operands env)
  ((operative-proc combiner) operands env))

(define (make-applicative proc)
  (kernel-wrap
   (make-operative
    (lambda (operands _)
      (apply proc operands)))))

(define (kernel-wrap proc)
  (applicative proc))

(define (kernel-unwrap appv)
  (applicative-proc appv))
