#lang racket

(require
 "src/core/boolean.rkt"
 "src/core/combiner.rkt"
 "src/core/control.rkt"
 "src/core/environment.rkt"
 "src/core/environment-mutation.rkt"
 "src/core/equivalence-under-mutation.rkt"
 "src/core/equivalence-up-to-mutation.rkt"
 "src/core/evaluator.rkt"
 "src/core/pair.rkt"
 "src/core/pair-mutation.rkt"
 "src/core/symbol.rkt"
 rackunit
 )

(provide
 (rename-out [module-begin #%module-begin]
             [top-interaction #%top-interaction]))

(define-syntax-rule (module-begin expr ...)
  (#%module-begin
   (begin
     (kernel-eval 'expr global-env)
     ...)))

(define-syntax-rule (top-interaction . expr)
  (kernel-eval 'expr global-env))

(define ground-environment (make-environment '()))

(define (make-ground-environment)
  (make-environment (list ground-environment)))

(define global-env (make-ground-environment))

(define (show-global-environment)
  (show-environment global-env))

(bind! ground-environment 'boolean? (make-applicative kernel-boolean?))
(bind! ground-environment 'eq? (make-applicative kernel-eq?))
(bind! ground-environment 'equal? (make-applicative kernel-equal?))
(bind! ground-environment 'symbol? (make-applicative kernel-symbol?))
(bind! ground-environment 'inert (make-applicative kernel-inert))
(bind! ground-environment 'inert? (make-applicative kernel-inert?))
(bind! ground-environment '$if (make-operative kernel-if))
(bind! ground-environment 'pair? (make-applicative kernel-pair?))
(bind! ground-environment 'null? (make-applicative kernel-null?))
(bind! ground-environment 'cons (make-applicative kernel-cons))
(bind! ground-environment 'set-car! (make-applicative kernel-set-car!))
(bind! ground-environment 'set-cdr! (make-applicative kernel-set-cdr!))
(bind! ground-environment 'copy-es-immutable (make-applicative kernel-copy-es-immutable))
(bind! ground-environment 'environment? (make-applicative environment?))
(bind! ground-environment 'ignore? (make-applicative kernel-ignore?))
(bind! ground-environment 'eval (make-applicative kernel-eval))
(bind! ground-environment 'make-environment (make-applicative make-environment))
(bind! ground-environment '$define! (make-operative kernel-define!))
(bind! ground-environment 'operative? (make-applicative operative?))
(bind! ground-environment 'applicative? (make-applicative applicative?))
(bind! ground-environment '$vau (make-operative kernel-vau))
(bind! ground-environment 'wrap (make-applicative kernel-wrap))
(bind! ground-environment 'unwrap (make-applicative kernel-unwrap))
(bind! ground-environment 'show-global-environment (make-applicative show-global-environment))
(bind! ground-environment 'make-ground-environment (make-applicative make-ground-environment))
(bind! ground-environment 'check-eq? (make-applicative check-eq?))
