#lang racket

(require
 "core/combiner.rkt"
 "core/control.rkt"
 "core/environment.rkt"
 "core/environment-mutation.rkt"
 "core/evaluator.rkt"
 "core/pair.rkt"
 rackunit
 )

(define ground-environment (make-environment '()))

(bind! ground-environment 'eval (make-applicative kernel-eval))
(bind! ground-environment 'wrap (make-applicative kernel-wrap))
(bind! ground-environment 'unwrap (make-applicative kernel-unwrap))
(bind! ground-environment 'cons (make-applicative kernel-cons))
(bind! ground-environment '$if (make-operative kernel-if))
(bind! ground-environment '$define (make-operative kernel-define))
(bind! ground-environment '$vau (make-operative kernel-vau))
; TODO: the rest

(define (make-ground-environment)
  (make-environment (list ground-environment)))

(test-begin
  (let ([truthy '($if #t 1 2)]
        [falsey '($if #f 1 2)]
        [throws '($if 3  1 2)])
    (check-eq? (kernel-eval truthy (make-ground-environment)) 1)
    (check-eq? (kernel-eval falsey (make-ground-environment)) 2)
    (check-exn exn:fail? (lambda () (kernel-eval throws (make-ground-environment))))))

(test-begin
  (letrec ([env (make-ground-environment)]
           [symbol (kernel-eval '($define a 1) env)]
           [pair (kernel-eval '($define (b . c) (cons 420 69)) env)]
           [list (kernel-eval '($define (d e f) (cons 6 (cons 7 (cons 8 ())))) env)])
    (check-true (kernel-inert? symbol))
    (check-true (kernel-inert? pair))
    (check-true (kernel-inert? list))
    (check-eq? (kernel-eval 'a env) 1)
    (check-eq? (kernel-eval 'b env) 420)
    (check-eq? (kernel-eval 'c env) 69)
    (check-eq? (kernel-eval 'd env) 6)
    (check-eq? (kernel-eval 'e env) 7)
    (check-eq? (kernel-eval 'f env) 8)))
