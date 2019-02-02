#lang racket

(provide kernel-symbol?)

(define (kernel-symbol? object)
  (and (not (eqv? object '|#ignore|))
       (symbol? object)))
