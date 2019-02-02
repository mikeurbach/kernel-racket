#lang racket

(require "environment.rkt" "combiner.rkt" "pair.rkt" "symbol.rkt")

(provide kernel-eval kernel-vau)

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

(define (kernel-vau args static-env)
  (letrec ([ptree (car args)]
           [eparam (cadr args)]
           [body (caddr args)])
    ;; (displayln (format "$vau: ptree = ~v, eparam = ~v" ptree eparam))
    (make-operative
     (lambda (operands dynamic-env)
       (let ([local-env (make-environment (list static-env))])
         (match! ptree operands local-env)
         (match! eparam dynamic-env local-env)
         (kernel-eval body local-env))))))
