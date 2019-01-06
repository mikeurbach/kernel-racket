#lang racket

(require "environment.rkt" "combiner.rkt" "pair.rkt")

(provide kernel-eval)

(define (kernel-eval expr env)
  (cond [(symbol? expr) (lookup expr env)]
        [(pair? expr)
         (combine (kernel-eval (mcar expr) env)
                  (mcdr expr)
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
