#lang racket

(require "environment.rkt" "combiner.rkt")

(provide (rename-out [kernel-eval eval]))

(define (mc-eval expr env)
  (cond [(symbol? expr) (lookup expr env)]
        [(pair? expr)
         (combine (mc-eval (mcar expr) env)
                  (mcdr expr)
                  env)]
        [#t expr]))

(define (mc-eval-list exprs env)
  (map
   (lambda (expr) (mc-eval expr env))
   exprs))

(define (combine combiner operands env)
  (if (operative? combiner)
      (operate combiner operands env)
      (combine (unwrap combiner)
               (mc-eval-list operands env)
               env)))

(define kernel-eval (make-applicative mc-eval))
