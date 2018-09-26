#lang racket

(define eval
  (lambda (expr env)
    (cond ((self-eval? expr) expr)
          ((quote? expr) (quote-value expr))
          (else (error "eval: won't evaluate" expr)))))

(define self-eval?
  (lambda (expr)
    (number? expr)))

(define quote?
  (lambda (expr) 
    (tagged? expr 'quote)))

(define quote-value
  (lambda (expr)
    (cadr expr)))

(define tagged?
  (lambda (expr tag)
    (if (pair? expr)
        (eq? (car expr) tag)
        false)))
