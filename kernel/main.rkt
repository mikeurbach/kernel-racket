#lang racket

(require
 "core.rkt"
 "library/base.rkt"
 rackunit
 )

(provide
 (rename-out [module-begin #%module-begin]
             [top-interaction #%top-interaction]))

(define-syntax-rule (module-begin expr ...)
  (#%module-begin
   expr
   ...))

(define-syntax-rule (top-interaction . expr)
  (kernel-eval 'expr global-env))
