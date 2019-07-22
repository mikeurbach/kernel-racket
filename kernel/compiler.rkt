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
  (end-with-linkage
   linkage
   (append
    (compile-operator expr)
    (compile-combiner-branch)
    (compile-unevaluated-operands expr)
    (compile-operate-branch)
    (list applicative-label)
    (compile-applicative-unwrap)
    (compile-evaluated-operands expr)
    (list operate-label)
    (compile-operate))))

(define (compile-operator expr)
  (compile (operator expr) 'proc 'next))

(define (compile-combiner-branch)
  `((branch (((op applicative?) (reg proc)) ,applicative-label))))

(define (compile-operate-branch)
  `((branch (#t ,operate-label))))

(define (compile-unevaluated-operands expr)
  `((assign (argl (const ,(operands expr))))))

(define (compile-applicative-unwrap)
  '((assign (proc (op unwrap) (reg proc)))))

(define (compile-evaluated-operands expr)
  (let ([operand-codes
         (map
          (lambda (operand) (compile operand 'val 'next))
          (reverse (operands expr)))])
    (if (empty? operand-codes)
        '((assign (argl (const ()))))
        (let ([last-operand-code
               (list
                (caar operand-codes)
                '(assign (argl (op list) (reg val))))])
          (if (empty? (cdr operand-codes))
              last-operand-code
              (append
               last-operand-code
               (compile-rest-operands (cdr operand-codes))))))))

(define (compile-rest-operands operand-codes)
  (let ([next-operand-code
         (list
          (caar operand-codes)
          '(assign (argl (op cons) (reg val) (reg argl))))])
    (if (empty? (cdr operand-codes))
        next-operand-code
        (append
         next-operand-code
         (compile-rest-operands (cdr operand-codes))))))

(define (compile-operate)
  '((assign (val (op operate) (reg proc) (reg argl) (reg env)))))

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

(define (operator expr) (car expr))
(define (operands expr) (cdr expr))
(define applicative-label 'applicative)
(define operate-label 'operate)
