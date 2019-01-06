#lang racket

(provide
 (rename-out [kernel-null? null?])
 (rename-out [kernel-pair? pair?])
 (rename-out [kernel-cons cons]))

(define kernel-null? null?)

(define kernel-pair? mpair?)

(define kernel-cons mcons)
