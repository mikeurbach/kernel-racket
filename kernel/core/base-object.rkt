#lang racket

(require "object.rkt")

(provide base-object%)

(define base-object%
  (class* object% (object)
    (super-new)
    (abstract type)
    (abstract repr)))
