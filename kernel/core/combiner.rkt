#lang racket

(provide make-operative operative? operate
         make-applicative kernel-wrap kernel-unwrap)

(struct operative (proc))
(struct applicative (proc))

(define (make-operative proc)
  (operative proc))

(define (operate combiner operands env)
  ((operative-proc combiner) operands env))

; we're going to override lamda and apply in the library
(define (make-applicative proc)
  (kernel-wrap
   (make-operative
    (lambda (operands _)
      (apply proc operands)))))

(define (kernel-wrap proc)
  (applicative proc))

(define (kernel-unwrap appv)
  (applicative-proc appv))
