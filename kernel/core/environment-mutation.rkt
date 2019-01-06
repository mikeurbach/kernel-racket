#lang racket

(require "environment.rkt" "evaluator.rkt")

(provide kernel-define)

(define (kernel-define args env)
  (letrec ([ptree (mcar args)]
           [expr (mcdr args)]
           [result (kernel-eval expr env)])
    (match! ptree expr env)
    '|#inert|))
