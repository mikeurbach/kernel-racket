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

(define (compile-self-evaluating expr target linkage)
  (end-with-linkage
   linkage
   `((assign (,target (const ,expr))))))

(define (compile-symbol-lookup expr target linkage)
  (end-with-linkage
   linkage
   `((assign (,target (op lookup) (const ,expr) (reg env))))))

(define (compile-combination expr target linkage)
  (let ([operator (combination-operator expr)]
        [operands (combination-operands expr)])
    (cond [(symbol? operator)
           (cond [(eq? operator '$if) (compile-if expr target linkage)]
                 [(eq? operator '$define!) (compile-define expr target linkage)]
                 [(eq? operator '$vau) (compile-vau expr target linkage)]
                 [(eq? operator 'wrap) (compile-wrap expr target linkage)]
                 [(eq? operator 'unwrap) (compile-unwrap expr target linkage)]
                 [(eq? operator 'eval) (compile-eval expr target linkage)] ;; ?
                 [else (compile-general-combination expr target linkage)])]
          [else
           (compile expr (proc-name "<anonymous>") 'next)])))

(define (compile-if expr target linkage)
  (letrec ([false-label (if-false-label "")]
           [done-label (if-done-label "")]
           [predicate (if-predicate expr)]
           [consequent (if-consequent expr)]
           [alternative (if-alternative expr)]
           [consequent-linkage (if (eq? linkage 'next) done-label linkage)])
    (append
     (compile-if-predicate predicate false-label)
     (compile consequent target consequent-linkage)
     (list false-label)
     (compile alternative target linkage)
     (list done-label))))

(define (compile-if-predicate predicate label)
  (letrec ([val (val-name "if")]
           [compiled-predicate (compile predicate val 'next)])
    (append
     compiled-predicate
     `((branch (((op eq?) (reg ,val) (const #f)) ,label))))))

(define (compile-define expr target linkage)
  'compiling-define)

(define (compile-vau expr target linkage)
  'compiling-vau)

(define (compile-wrap expr target linkage)
  'compiling-wrap)

(define (compile-unwrap expr target linkage)
  'compiling-unwrap)

(define (compile-eval expr target linkage)
  'compiling-eval)

(define (compile-general-combination expr target linkage)
  (letrec ([operator-name (if (symbol? (combination-operator expr)) (symbol->string (combination-operator expr)) "<operator>")]
           [label-for-applicative (applicative-prep-label operator-name)]
           [label-for-operate (operate-label operator-name)]
           [proc (proc-name operator-name)]
           [argl (argl-name operator-name)]
           [val (val-name operator-name)])
    (end-with-linkage
     linkage
     (append
      (compile-operator proc expr)
      (compile-combiner-branch proc label-for-applicative)
      (compile-unevaluated-operands argl expr)
      (compile-operate-branch label-for-operate)
      (list label-for-applicative)
      (compile-applicative-unwrap proc)
      (compile-evaluated-operands argl val expr)
      (list label-for-operate)
      (compile-operate proc argl target)))))

(define (compile-operator proc expr)
  (compile (combination-operator expr) proc 'next))

(define (compile-combiner-branch proc label)
  `((branch (((op applicative?) (reg ,proc)) ,label))))

(define (compile-unevaluated-operands argl expr)
  `((assign (,argl (const ,(combination-operands expr))))))

(define (compile-operate-branch label)
  `((branch (#t ,label))))

(define (compile-applicative-unwrap proc)
  `((assign (,proc (op unwrap) (reg ,proc)))))

(define (compile-evaluated-operands argl val expr)
  (let ([operand-codes (map (compile-operand val) (reverse (combination-operands expr)))])
    (if (empty? operand-codes)
        '((assign (argl (const ()))))
        (let ([last-operand-code
               (append
                (car operand-codes)
                `((assign (,argl (op list) (reg ,val)))))])
          (if (empty? (cdr operand-codes))
              last-operand-code
              (append
               last-operand-code
               (compile-rest-operands argl val (cdr operand-codes))))))))

(define (compile-operand val)
  (lambda (operand)
    (compile operand val 'next)))

(define (compile-rest-operands argl val operand-codes)
  (let ([next-operand-code
         (append
          (car operand-codes)
          `((assign (,argl (op cons) (reg ,val) (reg ,argl)))))])
    (if (empty? (cdr operand-codes))
        next-operand-code
        (append
         next-operand-code
         (compile-rest-operands (cdr operand-codes))))))

(define (compile-operate proc argl val)
  `((assign (,val (op operate) (reg ,proc) (reg ,argl) (reg env)))))

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

(define applicative-prep-label (unique-label "-applicative-prep-"))
(define operate-label  (unique-label "-operate-"))
(define if-false-label (unique-label "if-false-"))
(define if-done-label (unique-label "if-done-"))
(define proc-name (unique-label "-proc-"))
(define argl-name (unique-label "-argl-"))
(define val-name (unique-label "-val-"))

(define (if-predicate expr) (cadr expr))
(define (if-consequent expr) (caddr expr))
(define (if-alternative expr) (cadddr expr))
(define (combination-operator expr) (car expr))
(define (combination-operands expr) (cdr expr))

(define-syntax-rule (debug symbol)
  (displayln (format (string-append (symbol->string 'symbol) ": ~v") symbol)))
