#lang racket

(provide kernel-null? kernel-pair? kernel-cons)

(define kernel-null? null?)

(define kernel-pair? mpair?)

(define kernel-cons mcons)
