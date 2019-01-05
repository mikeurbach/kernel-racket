#lang racket

(require "base-object.rkt")

(provide boolean% (rename-out [boolean-object? boolean?]))

(define boolean%
  (class base-object%
    (super-new)
    (init-field value)
    (when (not (boolean? value))
      (raise-argument-error 'boolean% "boolean?" value))
    (define/override (repr) value)
    (define/override (type) 'boolean)))

(define (boolean-object? object)
  (eqv? (send object type) 'boolean))
