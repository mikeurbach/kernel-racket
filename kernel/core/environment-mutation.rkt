#lang racket

(require "environment.rkt" "evaluator.rkt")

(provide kernel-define)

(define (kernel-define args env)
  (letrec ([ptree (car args)]
           [expr (cadr args)]
           [result (kernel-eval expr env)])
    (match! ptree result env)
    '|#inert|))
