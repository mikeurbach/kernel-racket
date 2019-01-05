#lang racket

(provide
 (rename-out [kernel-null? null?])
 (rename-out [kernel-pair? pair?])
 (rename-out [kernel-cons cons]))

(define kernel-null? null?)

(define (kernel-pair? object)
  (or (pair? object)
      (mpair? object)))

(define kernel-cons mcons)
