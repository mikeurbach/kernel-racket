#lang racket

(require
 (only-in kernel global-env)
 "src/core/combiner.rkt"
 "src/core/environment.rkt"
 "src/core/pair.rkt"
 "src/core/symbol.rkt"
 "./../rtl/src/machine/vm.rkt")

(struct compound-operative (entry argl val continue))

(define compiler-environment (make-environment (list global-env)))
(bind! compiler-environment 'lookup (make-applicative lookup))
(bind! compiler-environment 'match! (make-applicative match!))
(bind! compiler-environment 'operate (make-applicative operate))
(bind! compiler-environment 'compound-operative (make-applicative compound-operative))
(bind! compiler-environment 'compound-operative? (make-applicative compound-operative?))
(bind! compiler-environment 'compound-operative-entry (make-applicative compound-operative-entry))
(bind! compiler-environment 'compound-operative-argl (make-applicative compound-operative-argl))
(bind! compiler-environment 'compound-operative-val (make-applicative compound-operative-val))
(bind! compiler-environment 'compound-operative-continue (make-applicative compound-operative-continue))

(define devnull 'devnull) ;; to implement side effects, assign to this register

(define prelude
  `((assign ((reg env) (const ,compiler-environment)))))

(define (compile-machine expr)
  (let ([instructions (append prelude (compile-list expr))])
    (new vm [instructions instructions] [environment compiler-environment])))

(define (compile-list exprs)
  (apply append (map (lambda (expr) (compile expr 'val 'next 'env)) exprs)))

(define (compile expr target linkage env)
  (cond [(kernel-symbol? expr) (compile-symbol-lookup expr target linkage env)]
        [(kernel-pair? expr) (compile-combination expr target linkage env)]
        [else (compile-self-evaluating expr target linkage)]))

(define (compile-self-evaluating expr target linkage)
  (end-with-linkage
   linkage
   `((assign ((reg ,target) (const ,expr))))))

(define (compile-symbol-lookup expr target linkage env)
  (end-with-linkage
   linkage
   `((assign ((reg ,target) (op lookup) (const ,expr) (reg ,env))))))

(define (compile-combination expr target linkage env)
  (let ([operator (combination-operator expr)]
        [operands (combination-operands expr)])
    (cond [(symbol? operator)
           (cond [(eq? operator '$if) (compile-if expr target linkage env)]
                 [(eq? operator '$define!) (compile-define expr target linkage env)]
                 [(eq? operator '$vau) (compile-vau expr target linkage env)]
                 [(eq? operator 'wrap) (compile-wrap expr target linkage env)]
                 [(eq? operator 'unwrap) (compile-unwrap expr target linkage env)]
                 [(eq? operator 'eval) (compile-eval expr target linkage env)] ;; ?
                 [else (compile-general-combination expr target linkage env)])]
          [else
           (compile expr (proc-name "<anonymous>") 'next env)])))

(define (compile-if expr target linkage env)
  (letrec ([false-label (if-false-label "")]
           [done-label (if-done-label "")]
           [predicate (if-predicate expr)]
           [consequent (if-consequent expr)]
           [alternative (if-alternative expr)]
           [consequent-linkage (if (eq? linkage 'next) done-label linkage)])
    (append
     (compile-if-predicate predicate false-label env)
     (compile consequent target consequent-linkage env)
     (list false-label)
     (compile alternative target linkage env)
     (list done-label))))

(define (compile-if-predicate predicate label env)
  (letrec ([val (val-name "if")]
           [compiled-predicate (compile predicate val 'next env)])
    (append
     compiled-predicate
     `((branch (((op eq?) (reg ,val) (const #f)) (const ,label)))))))

(define (compile-define expr target linkage env)
  (letrec ([ptree (define-ptree expr)]
           [val-expr (define-expr expr)]
           [val (val-name "define")]
           [compiled-expr (compile val-expr val 'next env)])
    (append
     compiled-expr
     `((assign ((reg ,devnull) (op match!) (const ,ptree) (reg ,val) (reg ,env)))
       (assign ((reg ,target) (op inert)))))))

(define (compile-vau expr target linkage env)
  (letrec ([entry (vau-entry-label "")]
           [after (vau-after-label "")]
           [argl (argl-name "compiled")]
           [val (val-name "compiled")]
           [continue (continue-name "compiled")]
           [local-env (env-name "local")]
           [vau-linkage (if (eq? linkage 'next) after linkage)])
    (append
     (end-with-linkage
      vau-linkage
      (compile-vau-constructor env target local-env entry argl val continue))
     (list entry)
     (compile-vau-body env expr local-env argl val continue)
     (list after))))

(define (compile-vau-constructor env target local-env entry argl val continue)
  `((assign ((reg ,local-env) (op list) (reg ,env)))
    (assign ((reg ,local-env) (op make-environment) (reg ,local-env)))
    (assign ((reg ,target) (op compound-operative) (const ,entry) (const ,argl) (const ,val) (const ,continue)))))

(define (compile-vau-body env expr local-env argl val continue)
  (let ([ptree (vau-ptree expr)]
        [eparam (vau-eparam expr)]
        [body (vau-body expr)])
    (append
     `((assign ((reg ,devnull) (op match!) (const ,ptree) (reg ,argl) (reg ,local-env)))
       (assign ((reg ,devnull) (op match!) (const ,eparam) (reg ,env) (reg ,local-env))))
     (compile body val continue local-env))))

(define (compile-wrap expr target linkage env)
  (letrec ([body (wrap-body expr)]
           [compiled-body (compile body target 'next env)])
    (end-with-linkage
     linkage
     (append
      compiled-body
      `((assign ((reg ,target) (op wrap) (reg ,target))))))))

(define (compile-unwrap expr target linkage env)
  (letrec ([body (unwrap-body expr)]
           [compiled-body (compile body target 'next env)])
    (end-with-linkage
     linkage
     (append
      compiled-body
      `((assign ((reg ,target) (op unwrap) (reg ,target))))))))

(define (compile-eval expr target linkage env)
  (let ([body (eval-body expr)]
        [env-name (eval-env expr)])
    (compile body target linkage env-name)))

(define (compile-general-combination expr target linkage env)
  (letrec ([operator-name (if (symbol? (combination-operator expr)) (symbol->string (combination-operator expr)) "<operator>")]
           [label-for-applicative (applicative-prep-label operator-name)]
           [label-for-operate (operate-label operator-name)]
           [label-for-compound (compound-label operator-name)]
           [label-for-done (compound-done-label operator-name)]
           [proc (proc-name operator-name)]
           [argl (argl-name operator-name)]
           [val (val-name operator-name)])
    (end-with-linkage
     linkage
     (append
      (compile-operator proc expr env)
      (compile-combiner-branch proc label-for-applicative)
      (compile-unevaluated-operands argl expr)
      (compile-operate-branch proc label-for-operate label-for-compound)
      (list label-for-applicative)
      (compile-applicative-unwrap proc)
      (compile-evaluated-operands argl val expr env)
      (compile-compound-branch proc label-for-compound)
      (list label-for-operate)
      (compile-operate proc argl target env)
      (compile-operate-done-branch label-for-done)
      (list label-for-compound)
      (compile-compound-operative operator-name target proc argl)
      (list label-for-done)))))

(define (compile-operator proc expr env)
  (compile (combination-operator expr) proc 'next env))

(define (compile-combiner-branch proc label)
  `((branch (((op applicative?) (reg ,proc)) (const ,label)))))

(define (compile-unevaluated-operands argl expr)
  `((assign ((reg ,argl) (const ,(combination-operands expr))))))

(define (compile-operate-branch proc operative-label compound-label)
  `((branch (((op compound-operative?) (reg ,proc)) (const ,compound-label))
            (#t (const ,operative-label)))))

(define (compile-operate-done-branch label)
  `((branch (#t (const ,label)))))

(define (compile-applicative-unwrap proc)
  `((assign ((reg ,proc) (op unwrap) (reg ,proc)))))

(define (compile-evaluated-operands argl val expr env)
  (let ([operand-codes (map (compile-operand val env) (reverse (combination-operands expr)))])
    (if (empty? operand-codes)
        '((assign ((reg argl) (const ()))))
        (let ([last-operand-code
               (append
                (car operand-codes)
                `((assign ((reg ,argl) (op list) (reg ,val)))))])
          (if (empty? (cdr operand-codes))
              last-operand-code
              (append
               last-operand-code
               (compile-rest-operands argl val (cdr operand-codes))))))))

(define (compile-operand val env)
  (lambda (operand)
    (compile operand val 'next env)))

(define (compile-rest-operands argl val operand-codes)
  (let ([next-operand-code
         (append
          (car operand-codes)
          `((assign ((reg ,argl) (op cons) (reg ,val) (reg ,argl)))))])
    (if (empty? (cdr operand-codes))
        next-operand-code
        (append
         next-operand-code
         (compile-rest-operands (cdr operand-codes))))))

(define (compile-compound-branch proc compound-label)
  `((branch (((op compound-operative?) (reg ,proc)) (const ,compound-label)))))

(define (compile-operate proc argl val env)
  `((assign ((reg ,val) (op operate) (reg ,proc) (reg ,argl) (reg ,env)))))

(define (compile-compound-operative operator-name target proc argl)
  (let ([entry (compound-entry-name operator-name)]
        [argl-alias (compound-argl-name operator-name)]
        [val-alias (compound-val-name operator-name)]
        [continue-alias (compound-continue-name operator-name)]
        [return (compound-return-label operator-name)])
    `((assign ((reg ,entry) (op compound-operative-entry) (reg ,proc))
              ((reg ,argl-alias) (op compound-operative-argl) (reg ,proc))
              ((reg ,val-alias) (op compound-operative-val) (reg ,proc))
              ((reg ,continue-alias) (op compound-operative-continue) (reg ,proc)))
      (assign ((alias ,argl-alias) (reg ,argl))
              ((alias ,continue-alias) (const ,return)))
      (branch (#t (reg ,entry)))
      ,return
      (assign ((reg ,target) (alias ,val-alias))))))


(define (compile-linkage linkage)
  (cond [(eq? linkage 'next)
         '()]
        [(string-contains? (symbol->string linkage) "continue")
         `((branch (#t (reg, linkage))))]
        [else
         `((branch (#t (const ,linkage))))]))

(define (end-with-linkage linkage instructions)
  (append instructions (compile-linkage linkage)))

(define (unique-label infix)
  (let ([count 0])
    (lambda (prefix)
      (set! count (+ 1 count))
      (string->symbol (string-append prefix infix (number->string count))))))

(define applicative-prep-label (unique-label "-applicative-prep-"))
(define operate-label  (unique-label "-operate-"))
(define compound-label  (unique-label "-compound-operative-"))
(define compound-return-label (unique-label "-compound-return-"))
(define compound-done-label (unique-label "-compound-done-"))
(define if-false-label (unique-label "if-false-"))
(define if-done-label (unique-label "if-done-"))
(define vau-entry-label (unique-label "vau-entry-"))
(define vau-after-label (unique-label "vau-after-"))
(define proc-name (unique-label "-proc-"))
(define argl-name (unique-label "-argl-"))
(define val-name (unique-label "-val-"))
(define continue-name (unique-label "-continue-"))
(define env-name (unique-label "-env-"))
(define compound-entry-name (unique-label "-compound-entry-"))
(define compound-argl-name (unique-label "-compound-argl-"))
(define compound-val-name (unique-label "-compound-val-"))
(define compound-continue-name (unique-label "-compound-continue-"))

;; these should be shared with interpreter
(define (if-predicate expr) (cadr expr))
(define (if-consequent expr) (caddr expr))
(define (if-alternative expr) (cadddr expr))
(define (define-ptree expr) (cadr expr))
(define (define-expr expr) (caddr expr))
(define (vau-ptree expr) (cadr expr))
(define (vau-eparam expr) (caddr expr))
(define (vau-body expr) (cadddr expr))
(define (wrap-body expr) (cadr expr))
(define (unwrap-body expr) (cadr expr))
(define (eval-body expr) (cadr expr))
(define (eval-env expr) (caddr expr))
(define (combination-operator expr) (car expr))
(define (combination-operands expr) (cdr expr))

(define-syntax-rule (debug symbol)
  (displayln (format (string-append (symbol->string 'symbol) ": ~v") symbol)))
