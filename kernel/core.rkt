#lang racket

(require
 "core/combiner.rkt"
 "core/control.rkt"
 "core/environment.rkt"
 "core/evaluator.rkt"
 )

(define ground-environment (make-environment '()))

(bind! ground-environment 'eval (make-applicative kernel-eval))
(bind! ground-environment 'wrap (make-applicative kernel-wrap))
(bind! ground-environment 'unwrap (make-applicative kernel-unwrap))
(bind! ground-environment '$if (make-operative kernel-if))
; TODO: $vau
; TODO: $define!
; TODO: ?
