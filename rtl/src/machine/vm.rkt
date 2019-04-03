#lang racket

(require "register.rkt" racket/hash)

(define vm
  (class object%
    (init-field instructions)

    (define (extract-registers insts)
      (if (empty? insts)
          (hasheq)
          (let ([inst-registers (extract-inst-registers (car insts))])
            (hash-union inst-registers (extract-registers (cdr insts))))))

    (define (extract-inst-registers instruction)
      (match instruction
        [(list 'assign name _) (hasheq name (register #f))]
        [_ (hasheq)]))

    (define (extract-execution-procs insts)
      (map extract-execution-proc insts))

    (define (extract-execution-proc instruction)
      (match instruction
        [(list 'assign name (list 'const value)) (make-assign-const name value)]
        [(list 'assign name (list 'reg arg-name)) (make-assign-reg name arg-name)]))

    (define (make-assign-const name value)
      (lambda ()
        (let ([register (hash-ref registers name)])
          (set-register-value! register value)
          (advance-pc!))))

    (define (make-assign-reg name arg-name)
      (lambda ()
        (let ([register (hash-ref registers name)]
              [arg-register (hash-ref registers arg-name)])
          (set-register-value! register (register-value arg-register))
          (advance-pc!))))

    (define (advance-pc!)
      (let ([new-pc (cdr (register-value pc))])
        (set-register-value! pc new-pc)))

    (define registers (extract-registers instructions))
    (define program (extract-execution-procs instructions))
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

    (super-new)))
