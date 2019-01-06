#lang racket

(require "environment.rkt" "combiner.rkt" "pair.rkt" "symbol.rkt")

(provide kernel-eval)

(define (kernel-eval expr env)
  (cond [(kernel-symbol? expr) (lookup expr env)]
        [(kernel-pair? expr)
         (combine (kernel-eval (car expr) env)
                  (cdr expr)
                  env)]
        [#t expr]))

(define (kernel-eval-list exprs env)
  (map
   (lambda (expr) (kernel-eval expr env))
   exprs))

(define (combine combiner operands env)
  (if (operative? combiner)
      (operate combiner operands env)
      (combine (kernel-unwrap combiner)
               (kernel-eval-list operands env)
               env)))
