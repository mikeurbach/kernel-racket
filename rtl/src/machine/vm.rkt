#lang racket

(require
 "../../../kernel/src/core/combiner.rkt"
 "../../../kernel/src/core/environment.rkt"
 "register.rkt"
 racket/hash)
(provide vm)

(define vm
  (class object%
    (init-field instructions)
    (init-field environment)

    (define (traverse-instructions processor insts)
      (if (empty? insts)
          (hash)
          (let ([processed (processor (car insts))]
                [tail (traverse-instructions processor (cdr insts))])
            (hash-union processed tail #:combine/key (lambda (k v1 v2) v2)))))

    (define (extract-inst-registers instruction)
      (match instruction
        [(list 'assign (list targets _ ...) ...)
         (traverse-instructions extract-assign-register targets)]
        [_ (hash)]))

    (define (extract-assign-register target)
      (match target
        [(list _ name) (hash name (register #f))]))

    (define (extract-inst-operators instruction)
      (match instruction
        [(list 'assign assignments ...)
         (traverse-instructions extract-assign-operator assignments)]
        [(list 'branch clauses ...)
         (traverse-instructions extract-branch-operator clauses)]
        [_ (hash)]))

    (define (extract-assign-operator assignment)
      (match assignment
        [(list _ (list 'op operator) _ ...)
         (hash operator (combiner-proc (lookup operator environment)))]
        [_ (hash)]))

    (define (extract-branch-operator clause)
      (match clause
        [(list (list (list 'op operator) _ ...) _)
         (hash operator (combiner-proc (lookup operator environment)))]
        [_ (hash)]))

    (define (combiner-proc combiner)
      (operative-proc (if (applicative? combiner)
                          (kernel-unwrap combiner)
                          combiner)))

    (define (extract-execution-procs insts)
      (map extract-execution-proc insts))

    (define (extract-execution-proc instruction)
      (match instruction
        [label #:when (symbol? label) label]
        [(list 'assign assignments ...)
         (make-assign assignments)]
        [(list 'branch (list predicates labels) ...)
         (make-branch predicates labels)]))

    (define (extract-basic-blocks insts)
      (if (empty? insts)
          (hash)
          (if (symbol? (car insts))
              (let ([pair (hash (car insts) (filter-execution-procs (cdr insts)))])
                (hash-union pair (extract-basic-blocks (cdr insts))))
              (extract-basic-blocks (cdr insts)))))

    (define (filter-execution-procs insts)
      (filter (compose1 not symbol?) insts))

    (define (make-assign assignments)
      (lambda ()
        (letrec ([registers-before (copy-registers)]
                 [assign-procs (map (make-assign-proc registers-before) assignments)])
          (for ([proc assign-procs])
            (proc))
          (advance-pc!))))

    (define (copy-registers)
      (apply hash (flatten (hash-map registers copy-register))))

    (define (copy-register name reg)
      (list name (register (register-value reg))))

    (define (make-assign-proc registers-before)
      (lambda (instruction)
        (match instruction
          [(list target (list 'const value))
           (make-assign-const target value)]
          [(list target (list 'reg arg-name))
           (make-assign-reg target arg-name registers-before)]
          [(list target (list 'alias arg-name))
           (make-assign-alias target arg-name registers-before)]
          [(list target (list 'op operator) inputs ...)
           (make-assign-op target operator inputs registers-before)])))

    (define (make-assign-const target value)
      (lambda ()
        (let ([register (assign-target-register target)])
          (set-register-value! register value))))

    (define (make-assign-reg target arg-name registers-before)
      (lambda ()
        (let ([register (assign-target-register target)]
              [arg-exp (make-register-exp arg-name registers-before)])
          (set-register-value! register (arg-exp)))))

    (define (make-assign-alias target arg-name registers-before)
      (lambda ()
        (let ([register (assign-target-register target)]
              [arg-exp (make-alias-exp arg-name registers-before)])
          (set-register-value! register (arg-exp)))))

    (define (make-assign-op target operator inputs registers-before)
      (let ([operator-proc (hash-ref operators operator)]
            [register (assign-target-register target)]
            [arg-exps (map (make-primitive-exp registers-before) inputs)])
        (lambda ()
          (let ([args (map (lambda (e) (e)) arg-exps)])
            (set-register-value! register (apply operator-proc (list args environment)))))))

    (define (assign-target-register target)
      (match target
        [(list 'reg name) (hash-ref registers name)]
        [(list 'alias name)
         (let ([alias-register (hash-ref registers name)])
           (hash-ref registers (register-value alias-register)))]))

    (define (make-branch predicates labels)
      (let ([predicate-procs (make-branch-predicates predicates)]
            [label-procs (map (make-primitive-exp registers) labels)])
        (lambda ()
          (test-branch-predicates predicate-procs label-procs))))

    (define (make-branch-predicates predicates)
      (if (empty? predicates)
          '()
          (cons (make-branch-predicate (car predicates))
                (make-branch-predicates (cdr predicates)))))

    (define (make-branch-predicate predicate)
      (match predicate
        [(list (list 'op operator) inputs ...)
         (let ([operator-proc (hash-ref operators operator)]
               [arg-exps (map (make-primitive-exp registers) inputs)])
           (lambda ()
             (let ([args (map (lambda (e) (e)) arg-exps)])
               (apply operator-proc (list args environment)))))]
        [#t (lambda () #t)]))

    (define (test-branch-predicates predicate-procs label-procs)
      (if (empty? predicate-procs)
          (advance-pc!)
          (let ([predicate-proc (car predicate-procs)]
                [label-proc (car label-procs)])
            (if (predicate-proc)
                (set-pc! (label-proc))
                (test-branch-predicates (cdr predicate-procs) (cdr label-procs))))))

    (define (make-primitive-exp registers-before)
      (lambda (expression)
        (match expression
          [(list 'const value) (make-const-exp value)]
          [(list 'reg name) (make-register-exp name registers-before)]
          [(list 'alias name) (make-alias-exp name registers-before)])))

    (define (make-const-exp value)
      (lambda () value))

    (define (make-register-exp name registers-before)
      (lambda ()
        (let ([register (hash-ref registers-before name)])
          (register-value register))))

    (define (make-alias-exp name registers-before)
      (lambda ()
        (letrec ([alias-register (hash-ref registers-before name)]
                 [target-register (hash-ref registers-before (register-value alias-register))])
          (register-value target-register))))

    (define (advance-pc!)
      (let ([new-pc (cdr (register-value pc))])
        (set-register-value! pc new-pc)))

    (define (set-pc! label)
      (let ([new-pc (hash-ref basic-blocks label)])
        (set-register-value! pc new-pc)))

    (define registers
      (traverse-instructions extract-inst-registers instructions))

    (define operators
      (traverse-instructions extract-inst-operators instructions))

    (define execution-procs (extract-execution-procs instructions))

    (define basic-blocks (extract-basic-blocks execution-procs))

    (define program (filter-execution-procs execution-procs))

    (define pc (register program))

    (define/public (execute)
      (let ([insts (register-value pc)])
        (if (empty? insts)
            'done
            (begin
              ((car insts))
              (execute)))))

    (define/public (vm-get-register-value name)
      (register-value (hash-ref registers name)))

    (define/public (vm-set-register-value! name value)
      (set-register-value! (hash-ref registers name) value))

    (define/public (get-execution-procs)
      execution-procs)

    (define/public (get-basic-blocks)
      basic-blocks)

    (define/public (get-instructions)
      instructions)

    (define/public (show-registers)
      (hash-for-each
       registers
       (lambda (key value)
         (displayln (format "~v: ~v" key (register-value value))))))

    (super-new)))
