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
; TODO: $vau
; TODO: the rest

(define (make-ground-environment)
  (make-environment (list ground-environment)))

(test-begin
  (let ([truthy (mcons '$if (mcons #t (mcons 1 (mcons 2 '()))))]
        [falsey (mcons '$if (mcons #f (mcons 1 (mcons 2 '()))))]
        [throws (mcons '$if (mcons 3 (mcons 1 (mcons 2 '()))))])
    (check-eq? (kernel-eval truthy (make-ground-environment)) 1)
    (check-eq? (kernel-eval falsey (make-ground-environment)) 2)
    (check-exn exn:fail? (lambda () (kernel-eval throws (make-ground-environment))))))

(test-begin
  (letrec ([env (make-ground-environment)]
           [single (kernel-eval (mcons '$define (mcons 'a 1)) env)])
    (check-true (kernel-inert? single))
    (check-eq? (kernel-eval 'a env) 1)))
