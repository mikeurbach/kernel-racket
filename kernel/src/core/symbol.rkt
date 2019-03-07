#lang racket

(provide kernel-symbol?)

;; TODO: maybe don't use |#ignore| symbol directly in the evaluator logic
(define (kernel-symbol? object)
  (and (not (eqv? object '|#ignore|))
       (symbol? object)))
