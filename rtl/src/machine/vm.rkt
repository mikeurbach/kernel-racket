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
         (make-assign-op name operator inputs)]))

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
            [arg-exps (map (lambda (e) (make-primitive-exp e)) inputs)])
        (lambda ()
          (let ([args (map (lambda (e) (e)) arg-exps)])
            (set-register-value! register (apply operator-proc args))
            (advance-pc!)))))

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

    (define registers
      (traverse-instructions extract-inst-registers instructions))

    (define operators
      (traverse-instructions extract-inst-operators instructions))

    (define execution-procs (extract-execution-procs instructions))

    (define basic-blocks (extract-basic-blocks execution-procs))

    (define program (filter (lambda (p) (not (symbol? p))) execution-procs))

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
