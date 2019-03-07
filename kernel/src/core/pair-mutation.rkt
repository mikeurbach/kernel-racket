#lang racket

; this is not very useful, since there is no way to create mutable pairs.

(provide kernel-set-car! kernel-set-cdr! kernel-copy-es-immutable)

(define (kernel-set-car! object value)
  (set-mcar! object value))

(define (kernel-set-cdr! object value)
  (set-mcdr! object value))

(define (kernel-copy-es-immutable object)
  (if (not (pair? object))
      object
      (let ([new-car (kernel-copy-es-immutable (mcar object))]
            [new-cdr (kernel-copy-es-immutable (mcdr object))])
        (cons new-car new-cdr))))
