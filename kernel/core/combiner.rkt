#lang racket

(provide make-operative operative? operate
         make-applicative wrap unwrap)

(struct operative (proc))
(struct applicative (proc))

(define (make-operative proc)
  (operative proc))

(define (operate combiner operands env)
  ((operative-proc combiner) operands env))

; racket doesn't know that we're overriding lamda and apply in the library,
; so this is legal syntax
(define (make-applicative proc)
  (mc-wrap
   (make-operative
    (lambda (operands _)
      (apply proc operands)))))

(define (mc-wrap proc)
  (applicative proc))

(define (mc-unwrap appv)
  (applicative-proc appv))

(define wrap (make-applicative mc-wrap))
(define unwrap (make-applicative mc-unwrap))
