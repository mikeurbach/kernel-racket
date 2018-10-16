#lang racket

;; from SICP 4.1 and 5.4 footnotes

(provide (all-defined-out))
(require "stack.rkt")

(define (self-evaluating? expr)
  (or (number? expr)
      (string? expr)))

(define (variable? expr) (symbol? expr))

(define (quoted? expr)
  (tagged-list? expr 'quote))

(define (text-of-quotation expr) (cadr expr))

(define (tagged-list? expr tag)
  (if (pair? expr)
      (eq? (car expr) tag)
      false))

(define (assignment? expr)
  (tagged-list? expr 'set!))
(define (assignment-variable expr) (cadr expr))
(define (assignment-value expr) (caddr expr))

(define (definition? expr)
  (tagged-list? expr 'define))
(define (definition-variable expr)
  (if (symbol? (cadr expr))
      (cadr expr)
      (caadr expr)))
(define (definition-value expr)
  (if (symbol? (cadr expr))
      (caddr expr)
      (make-lambda (cdadr expr)   ; formal parameters
                   (cddr expr)))) ; body
(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))

(define (make-procedure parameters body env)
  (list 'procedure parameters body env))
(define (primitive-procedure? p)
  (tagged-list? p 'primitive))
(define (compound-procedure? p)
  (tagged-list? p 'procedure))
(define (procedure-parameters p) (cadr p))
(define (procedure-body p) (caddr p))
(define (procedure-environment p) (cadddr p))
(define (apply-primitive-procedure p args)
  (apply (cadr p) args))

(define (empty-arglist) '())
(define (adjoin-arg arg arglist)
  (append arglist (list arg)))

(define (if? expr) (tagged-list? expr 'if))
(define (if-predicate expr) (cadr expr))
(define (if-consequent expr) (caddr expr))
(define (if-alternative expr)
  (if (not (empty? (cdddr expr)))
      (cadddr expr)
      'false))

(define (true? x)
  (not (eq? x false)))
(define (false? x)
  (eq? x false))

(define (lambda? expr) (tagged-list? expr 'lambda))
(define (lambda-parameters expr) (cadr expr))
(define (lambda-body expr) (cddr expr))

(define (begin? expr) (tagged-list? expr 'begin))
(define (begin-actions expr) (cdr expr))
(define (last-expr? seq) (empty? (cdr seq)))
(define (first-expr seq) (car seq))
(define (rest-exprs seq) (cdr seq))
(define (no-more-exprs? seq) (empty? seq))

(define (application? expr) (pair? expr))
(define (operator expr) (car expr))
(define (operands expr) (cdr expr))
(define (no-operands? ops) (empty? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))
(define (last-operand? ops) (empty? (cdr ops)))

(define (enclosing-environment env) (cdr env))
(define (first-frame env) (car env))
(define the-empty-environment '())

(define (make-frame vars vals)
  (make-hasheq (map cons vars vals)))

(define (get-binding-from-frame frame var)
  (if (hash-has-key? frame var)
      (hash-ref frame var)
      #f))

(define (add-binding-to-frame! frame var val)
  (hash-set! frame var val))

(define (extend-environment vars vals base-env)
  (if (= (length vars) (length vals))
      (cons (make-frame vars vals) base-env)
      (error "number of variables and values must match")))

(define (lookup-variable-value var env)
  (if (eq? env the-empty-environment)
      (error "unbound variable" var)
      (let ([frame (first-frame env)])
        (let ([val (get-binding-from-frame frame var)])
          (or val (lookup-variable-value var (enclosing-environment env)))))))

(define (set-variable-value! var val env)
  (if (eq? env the-empty-environment)
      (error "unbound variable" var)
      (let ([frame (first-frame env)])
        (let ([oldval (get-binding-from-frame frame var)])
          (if oldval
              (add-binding-to-frame! frame var val)
              (set-variable-value! var val (enclosing-environment env)))))))

(define (define-variable! var val env)
  (let ([frame (first-frame env)])
    (add-binding-to-frame! frame var val)))

(define primitive-procedures
  '(empty? eq? cons car cdr cadr cddr + * - / foldl map length flatten))

(define (make-primitive-procedure name)
  `(primitive ,(eval name)))

(define (setup-environment)
  (extend-environment
   primitive-procedures
   (map make-primitive-procedure primitive-procedures)
   the-empty-environment))

(define the-global-environment (setup-environment))
(define (get-global-environment) the-global-environment)

(define (prompt-for-input str)
  (newline)
  (newline)
  (displayln str))

(define (announce-output str)
  (newline)
  (displayln str))

(define (user-print obj)
  (display obj))
