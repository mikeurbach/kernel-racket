#lang racket

(provide (rename-out [kernel-eq? eq?]))

(define kernel-eq? eqv?)
