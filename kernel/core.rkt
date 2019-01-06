#lang racket

(require
 "core/combiner.rkt"
 "core/control.rkt"
 "core/environment.rkt"
 "core/environment-mutation.rkt"
 "core/evaluator.rkt"
 rackunit
 )

(define ground-environment (make-environment '()))

(bind! ground-environment 'eval (make-applicative kernel-eval))
(bind! ground-environment 'wrap (make-applicative kernel-wrap))
(bind! ground-environment 'unwrap (make-applicative kernel-unwrap))
(bind! ground-environment '$if (make-operative kernel-if))
(bind! ground-environment '$define (make-operative kernel-define))
; TODO: $vau
; TODO: the rest

; TODO: standard environment

(test-begin
  (let ([truthy (mcons '$if (mcons #t (mcons 1 (mcons 2 '()))))]
        [falsey (mcons '$if (mcons #f (mcons 1 (mcons 2 '()))))]
        [throws (mcons '$if (mcons 3 (mcons 1 (mcons 2 '()))))])
    (check-eq? (kernel-eval truthy ground-environment) 1)
    (check-eq? (kernel-eval falsey ground-environment) 2)
    (check-exn exn:fail? (lambda () (kernel-eval throws ground-environment)))))

(test-begin
  (let ([result (kernel-eval (mcons '$define (mcons 'a 420)) ground-environment)])
    (check-true (kernel-inert? result))
    (check-eq? (kernel-eval 'a ground-environment) 420)))
