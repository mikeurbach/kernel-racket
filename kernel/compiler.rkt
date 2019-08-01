#lang racket

(require
 (only-in kernel global-env)
 "src/core/combiner.rkt"
 "src/core/environment.rkt"
 "src/core/pair.rkt"
 "src/core/symbol.rkt"
 "./../rtl/src/machine/vm.rkt")

(define compiler-environment (make-environment (list global-env)))
(bind! compiler-environment 'lookup (make-applicative lookup))
(bind! compiler-environment 'operate (make-applicative operate))

(define prelude
  `((assign (env (const ,compiler-environment)))))

(define (compile-machine expr)
  (let ([instructions
         (append
          prelude
          (compile expr 'val 'next))])
    (new vm [instructions instructions] [environment compiler-environment])))

(define (compile expr target linkage)
  (cond [(kernel-symbol? expr) (compile-symbol-lookup expr target linkage)]
        [(kernel-pair? expr) (compile-combination expr target linkage)]
        [else (compile-self-evaluating expr target linkage)]))

(define (compile-symbol-lookup expr target linkage)
  (end-with-linkage
   linkage
   `((assign (,target (op lookup) (const ,expr) (reg env))))))

(define (compile-combination expr target linkage)
  'compiling-combination)

(define (compile-self-evaluating expr target linkage)
  (end-with-linkage
   linkage
   `((assign (,target (const ,expr))))))

(define (compile-linkage linkage)
  (cond [(eq? linkage 'return)
         '((branch (#t continue)))]
        [(eq? linkage 'next)
         '()]
        [else
         `((branch (#t ,linkage)))]))

(define (end-with-linkage linkage instructions)
  (append instructions (compile-linkage linkage)))

(define (unique-label infix)
  (let ([count 0])
    (lambda (prefix)
      (set! count (+ 1 count))
      (string->symbol (string-append prefix infix (number->string count))))))

(define (operator expr) (car expr))
(define (operands expr) (cdr expr))

(define-syntax-rule (debug symbol)
  (displayln (format (string-append (symbol->string 'symbol) ": ~v") symbol)))
