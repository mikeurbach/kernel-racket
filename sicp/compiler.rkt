#lang s-exp syntax/module-reader
"expander.rkt"
#:read read
#:read-syntax my-read-syntax

(require racket (except-in "primitives.rkt" false?))
(provide compiler)

(define (my-read-syntax src in)
  (define input-stx (read-syntax src in))
  (if (eof-object? input-stx)
      eof
      (datum->instructions (syntax->datum input-stx))))

(define (datum->instructions input-datum)
  (define prelude
    '((assign env (op get-global-environment))))
  (define compiled
    (caddr (compiler input-datum 'val 'next)))
  (with-syntax ([instructions (cons 'controller (append prelude compiled))])
    #'instructions))

(define (compiler expr target linkage)
  (cond [(self-evaluating? expr)
         (compile-self-evaluating expr target linkage)]
        [(quoted? expr)
         (compile-quoted expr target linkage)]
        [(variable? expr)
         (compile-variable expr target linkage)]
        [(assignment? expr)
         (compile-assignment expr target linkage)]
        [(definition? expr)
         (compile-definition expr target linkage)]
        [(if? expr)
         (compile-if expr target linkage)]
        [(cond? expr)
         (compiler (cond->if expr) target linkage)]
        [(begin? expr)
         (compile-sequence (begin-actions expr) target linkage)]
        [(lambda? expr)
         (compile-lambda expr target linkage)]
        [(application? expr)
         (compile-application expr target linkage)]
        [else
         (error (format "compile: unknown expression type ~v" expr))]))

(define (compile-self-evaluating expr target linkage)
  (end-with-linkage
   linkage
   (make-instruction-sequence
    (set) (set target)
    `((assign ,target (const ,expr))))))

(define (compile-quoted expr target linkage)
  (end-with-linkage
   linkage
   (make-instruction-sequence
    (set) (set target)
    `((assign ,target (const ,(text-of-quotation expr)))))))

(define (compile-variable expr target linkage)
  (end-with-linkage
   linkage
   (make-instruction-sequence
    (set 'env) (set target)
    `((assign ,target (op lookup-variable-value) (const ,expr) (reg env))))))

(define (compile-assignment expr target linkage)
  (let ([var (assignment-variable expr)]
        [code-for-value (compiler (assignment-value expr) 'val 'next)])
    (end-with-linkage
     linkage
     (preserving
      '(env)
      code-for-value
      (make-instruction-sequence
       (set 'env 'val)
       (set target)
       `((perform (op set-variable-value!) (const ,var) (reg val) (reg env))
         (assign ,target (const ok))))))))

(define (compile-definition expr target linkage)
  (let ([var (definition-variable expr)]
        [code-for-value (compiler (definition-value expr) 'val 'next)])
    (end-with-linkage
     linkage
     (preserving
      '(env)
      code-for-value
      (make-instruction-sequence
       (set 'env 'val)
       (set target)
       `((perform (op define-variable!) (const ,var) (reg val) (reg env))
         (assign ,target (const ok))))))))

(define (compile-if expr target linkage)
  (let ([t-branch (make-label 'true-branch)]
        [f-branch (make-label 'false-branch)]
        [after-if (make-label 'after-if)])
    (let ([consequent-linkage (if (eq? linkage 'next) after-if linkage)])
      (let ([p-code (compiler (if-predicate expr) 'val 'next)]
            [c-code (compiler (if-consequent expr) target consequent-linkage)]
            [a-code (compiler (if-alternative expr) target linkage)])
        (preserving
         '(env continue)
         p-code
         (append-instruction-sequences
          (make-instruction-sequence
           (set 'val)
           (set)
           `((test (op false?) (reg val))
             (branch (label ,f-branch))))
          (parallel-instruction-sequences
           (append-instruction-sequences t-branch c-code)
           (append-instruction-sequences f-branch a-code))
          after-if))))))

(define (compile-sequence seq target linkage)
  (if (last-expr? seq)
      (compiler (first-expr seq) target linkage)
      (preserving
       '(env continue)
       (compiler (first-expr seq) target 'next)
       (compile-sequence (rest-exprs seq) target linkage))))

(define (compile-lambda expr target linkage)
  (let ([proc-entry (make-label 'entry)]
        [after-lambda (make-label 'after-lambda)])
    (let ([lambda-linkage (if (eq? linkage 'next) after-lambda linkage)])
      (append-instruction-sequences
       (tack-on-instruction-sequence
        (end-with-linkage
         lambda-linkage
         (make-instruction-sequence
          (set 'env)
          (set target)
          `((assign ,target
                    (op make-compiled-procedure)
                    (label ,proc-entry)
                    (reg env)))))
        (compile-lambda-body expr proc-entry))
       after-lambda))))

(define (compile-lambda-body expr proc-entry)
  (let ([formals (lambda-parameters expr)])
    (append-instruction-sequences
     (make-instruction-sequence
      (set 'env 'proc 'argl)
      (set 'env)
      `(,proc-entry
        (assign env (op compiled-procedure-env) (reg proc))
        (assign env (op extend-environment) (const ,formals) (reg argl) (reg env))))
     (compile-sequence (lambda-body expr) 'val 'return))))

(define (compile-application expr target linkage)
  (let ([proc-code (compiler (operator expr) 'proc 'next)]
        [operand-codes
         (map (lambda (operand) (compiler operand 'val 'next)) (operands expr))])
    (preserving
     '(env continue)
     proc-code
     (preserving
      '(proc continue)
      (construct-arglist operand-codes)
      (compile-procedure-call target linkage)))))

(define (construct-arglist operand-codes)
  (let ([operand-codes (reverse operand-codes)])
    (if (null? operand-codes)
        (make-instruction-sequence (set) (set 'argl) '((assign argl (const ()))))
        (let ([code-to-get-last-arg
               (append-instruction-sequences
                (car operand-codes)
                (make-instruction-sequence
                 (set 'val)
                 (set 'argl)
                 '((assign argl (op list) (reg val)))))])
          (if (null? (cdr operand-codes))
              code-to-get-last-arg
              (preserving
               '(env)
               code-to-get-last-arg
               (code-to-get-rest-args (cdr operand-codes))))))))

(define (code-to-get-rest-args operand-codes)
  (let ([code-for-next-arg
         (preserving
          '(argl)
          (car operand-codes)
          (make-instruction-sequence
           (set 'val 'argl)
           (set 'argl)
           '((assign argl (op cons) (reg val) (reg argl)))))])
    (if (null? (cdr operand-codes))
        code-for-next-arg
        (preserving
         '(env)
         (code-to-get-rest-args (cdr operand-codes))))))

(define (compile-procedure-call target linkage)
  (let ([primitive-branch (make-label 'primitive-branch)]
        [compiled-branch (make-label 'compiled-branch)]
        [after-call (make-label 'after-call)])
    (let ([compiled-linkage (if (eq? linkage 'next) after-call linkage)])
      (append-instruction-sequences
       (make-instruction-sequence
        (set 'proc)
        (set)
        `((test (op primitive-procedure?) (reg proc))
          (branch (label ,primitive-branch))))
       (parallel-instruction-sequences
        (append-instruction-sequences
         compiled-branch
         (compile-proc-appl target compiled-linkage))
        (append-instruction-sequences
         primitive-branch
         (end-with-linkage
          linkage
          (make-instruction-sequence
           (set 'proc 'argl)
           (set target)
           `((assign ,target (op apply-primitive-procedure) (reg proc) (reg argl)))))))
       after-call))))

(define all-regs (set 'env 'proc 'val 'argl 'continue))

(define (compile-proc-appl target linkage)
  (cond [(and (eq? target 'val) (not (eq? linkage 'return)))
         (make-instruction-sequence
          (set 'proc)
          all-regs
          `((assign continue (label ,linkage))
            (assign val (op compiled-procedure-entry) (reg proc))
            (goto (reg val))))]
        [(and (not (eq? target 'val)) (not (eq? linkage 'return)))
         (let ([proc-return (make-label 'proc-return)])
           (make-instruction-sequence
            (set 'proc)
            all-regs
            `((assign continue (label ,proc-return))
              (assign val (op compiled-procedure-entry) (reg proc))
              (goto (reg val))
              ,proc-return
              (assign ,target (reg val))
              (goto (label ,linkage)))))]
        [(and (eq? target 'val) (eq? linkage 'return))
         (make-instruction-sequence
          (set 'proc 'continue)
          all-regs
          '((assign val (op compiled-procedure-entry) (reg proc))
            (goto (reg val))))]
        [(and (not (eq? target 'val)) (eq? linkage 'return))
         (error (format "compile: return linkage, target not val: ~v" target))]))
        

(define (compile-linkage linkage)
  (cond [(eq? linkage 'return)
         (make-instruction-sequence (set 'continue) (set) '((goto (reg continue))))]
        [(eq? linkage 'next)
         (empty-instruction-sequence)]
        [else
         (make-instruction-sequence (set) (set) `((goto (label ,linkage))))]))

(define (end-with-linkage linkage instruction-sequence)
  (preserving
   '(continue)
   instruction-sequence
   (compile-linkage linkage)))

(define (make-instruction-sequence needs modifies statements)
  (list needs modifies statements))

(define (empty-instruction-sequence)
  (make-instruction-sequence (set) (set) '()))

(define (registers-needed seq)
  (if (symbol? seq) (set) (car seq)))
(define (registers-modified seq)
  (if (symbol? seq) (set) (cadr seq)))
(define (statements seq)
  (if (symbol? seq) (list seq) (caddr seq)))

(define (needs-register? seq reg)
  (set-member? (registers-needed seq) reg))
(define (modifies-register? seq reg)
  (set-member? (registers-modified seq) reg))

(define (append-instruction-sequences . seqs)
  (define (combine-seqs seq1 seq2)
    (make-instruction-sequence
     (set-union (registers-needed seq1)
                (set-subtract (registers-needed seq2)
                              (registers-modified seq1)))
     (set-union (registers-modified seq1)
                (registers-modified seq2))
     (append (statements seq1) (statements seq2))))
  (define (reduce-seqs seqs)
    (if (null? seqs)
        (empty-instruction-sequence)
        (combine-seqs (car seqs)
                      (reduce-seqs (cdr seqs)))))
  (reduce-seqs seqs))

(define (parallel-instruction-sequences seq1 seq2)
  (make-instruction-sequence
   (set-union (registers-needed seq1)
              (registers-needed seq2))
   (set-union (registers-modified seq1)
              (registers-modified seq2))
   (append (statements seq1) (statements seq2))))

(define (tack-on-instruction-sequence seq1 seq2)
  (make-instruction-sequence
   (registers-needed seq1)
   (registers-modified seq1)
   (append (statements seq1) (statements seq2))))

(define (preserving regs seq1 seq2)
  (if (null? regs)
      (append-instruction-sequences seq1 seq2)
      (let ([first-reg (car regs)])
        (if (and (needs-register? seq2 first-reg)
                 (modifies-register? seq1 first-reg))
            (preserving
             (cdr regs)
             (make-instruction-sequence
              (set-union (set first-reg) (registers-needed seq1))
              (set-subtract (registers-modified seq1) (set first-reg))
              (append
               `((save ,first-reg))
               (statements seq1)
               `((restore ,first-reg))))
             seq2)
            (preserving (cdr regs) seq1 seq2)))))

(define label-counter 0)

(define (new-label-number)
  (set! label-counter (+ label-counter 1))
  label-counter)

(define (make-label name)
  (string->symbol
   (string-append (symbol->string name)
                  (number->string (new-label-number)))))
