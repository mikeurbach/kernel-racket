#lang racket

(require
 "core/boolean.rkt"
 "core/combiner.rkt"
 "core/control.rkt"
 "core/environment.rkt"
 "core/environment-mutation.rkt"
 "core/equivalence-under-mutation.rkt"
 "core/equivalence-up-to-mutation.rkt"
 "core/evaluator.rkt"
 "core/pair.rkt"
 "core/pair-mutation.rkt"
 "core/symbol.rkt"
 rackunit
 )

(provide make-ground-environment kernel-eval)

(define ground-environment (make-environment '()))

(bind! ground-environment 'boolean? (make-applicative kernel-boolean?))
(bind! ground-environment 'eq? (make-applicative kernel-eq?))
(bind! ground-environment 'equal? (make-applicative kernel-equal?))
(bind! ground-environment 'symbol? (make-applicative kernel-symbol?))
(bind! ground-environment 'inert? (make-applicative kernel-symbol?))
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
           [symbol (kernel-eval '($define! a 1) env)]
           [pair (kernel-eval '($define! (b . c) (cons 420 69)) env)]
           [list (kernel-eval '($define! (d e f) (cons 6 (cons 7 (cons 8 ())))) env)])
    (check-true (kernel-inert? symbol))
    (check-true (kernel-inert? pair))
    (check-true (kernel-inert? list))
    (check-eq? (kernel-eval 'a env) 1)
    (check-eq? (kernel-eval 'b env) 420)
    (check-eq? (kernel-eval 'c env) 69)
    (check-eq? (kernel-eval 'd env) 6)
    (check-eq? (kernel-eval 'e env) 7)
    (check-eq? (kernel-eval 'f env) 8)))
