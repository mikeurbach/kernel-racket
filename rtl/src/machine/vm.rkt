#lang racket

(require "register.rkt" racket/hash)

(define vm
  (class object%
    (init-field instructions)

    (define (traverse-instructions processor insts)
      (if (empty? insts)
          (hash)
          (let ([processed (processor (car insts))]
                [tail (traverse-instructions processor (cdr insts))])
            (hash-union processed tail #:combine/key (lambda (k v1 v2) v2)))))

    (define (extract-inst-registers instruction)
      (match instruction
        [(list 'assign name _ ...) (hash name (register #f))]
        [_ (hash)]))

    (define (extract-inst-operators instruction)
      (match instruction
        [(list 'assign _ (list 'op operator) _ ...)
         (hash operator (eval operator))]
        [(list 'branch (list (list (list 'op operator) _ ...) _ ...) _ ...)
         (hash operator (eval operator))]
        [_ (hash)]))

    (define (extract-execution-procs insts)
      (map extract-execution-proc insts))

    (define (extract-execution-proc instruction)
      (match instruction
        [label #:when (symbol? label) label]
        [(list 'assign name (list 'const value))
         (make-assign-const name value)]
        [(list 'assign name (list 'reg arg-name))
         (make-assign-reg name arg-name)]
        [(list 'assign name (list 'op operator) inputs ...)
         (make-assign-op name operator inputs)]
        [(list 'branch (list predicates labels) ...)
         (make-branch predicates labels)]))

    (define (extract-basic-blocks insts)
      (if (empty? insts)
          (hash)
          (if (symbol? (car insts))
              (let ([pair (hash (car insts) (cdr insts))])
                (hash-union pair (extract-basic-blocks (cdr insts))))
              (extract-basic-blocks (cdr insts)))))

    (define (make-assign-const name value)
      (lambda ()
        (let ([register (hash-ref registers name)])
          (set-register-value! register value)
          (advance-pc!))))

    (define (make-assign-reg name arg-name)
      (lambda ()
        (let ([register (hash-ref registers name)]
              [arg-exp (make-register-exp arg-name)])
          (set-register-value! register (arg-exp))
          (advance-pc!))))

    (define (make-assign-op name operator inputs)
      (let ([operator-proc (hash-ref operators operator)]
            [register (hash-ref registers name)]
            [arg-exps (map make-primitive-exp inputs)])
        (lambda ()
          (let ([args (map (lambda (e) (e)) arg-exps)])
            (set-register-value! register (apply operator-proc args))
            (advance-pc!)))))

    (define (make-branch predicates labels)
      (let ([predicate-procs (make-branch-predicates predicates)])
        (lambda ()
          (test-branch-predicates predicate-procs labels))))

    (define (make-branch-predicates predicates)
      (if (empty? predicates)
          '()
          (cons (make-branch-predicate (car predicates)) (cdr predicates))))

    (define (make-branch-predicate predicate)
      (match predicate
        [(list (list 'op operator) inputs ...)
         (let ([operator-proc (hash-ref operators operator)]
               [arg-exps (map make-primitive-exp inputs)])
           (lambda ()
             (let ([args (map (lambda (e) (e)) arg-exps)])
               (apply operator-proc args))))]
        [#t (lambda () #t)]))

    (define (test-branch-predicates predicate-procs labels)
      (if (empty? predicate-procs)
          (advance-pc!)
          (let ([predicate-proc (car predicate-procs)]
                [label (car labels)])
            (if (predicate-proc)
                (set-pc! label)
                (test-branch-predicates (cdr predicate-procs) (cdr labels))))))

    (define (make-primitive-exp expression)
      (match expression
        [(list 'const value) (make-const-exp value)]
        [(list 'reg name) (make-register-exp name)]))

    (define (make-const-exp value)
      (lambda () value))

    (define (make-register-exp name)
      (lambda ()
        (let ([register (hash-ref registers name)])
          (register-value register))))

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

    (define program (filter (compose1 not symbol?) execution-procs))

    (define pc (register program))

    (define/public (execute)
      (let ([insts (register-value pc)])
        (if (empty? insts)
            'done
            (begin
              ((car insts))
              (execute)))))

    (define/public (get-registers)
      registers)

    (define/public (get-operators)
      operators)

    (define/public (get-program)
      program)

    (define/public (get-basic-blocks)
      basic-blocks)

    (super-new)))
