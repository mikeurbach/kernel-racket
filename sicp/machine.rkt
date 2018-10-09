#lang racket

(require racket/hash "register.rkt" "stack.rkt" "assembler.rkt")
(provide make-machine machine-set-register! machine-get-register machine-start)

(define (make-machine register-names ops controller-text)
  (let ((machine (machine-new)))
    (for/list ([register-name register-names])
      ((machine 'allocate-register) register-name))
    ((machine 'install-operations) ops)
    ((machine 'install-instruction-sequence)
     (assemble controller-text machine))
    machine))

(define (machine-new)
  (let ([pc (register-new 'pc)]
        [flag (register-new 'flag)]
        [stack (stack-new)]
        [instructions '()])
    (let ([operations
           (let ([table (make-hasheq)])
             (hash-set! table 'initialize-stack
                        (lambda () (stack-initialize stack)))
             table)]
          [registers
           (let ([table (make-hasheq)])
             (hash-set! table 'pc pc)
             (hash-set! table 'flag flag)
             table)])
      (define (allocate-register name)
        (if (hash-has-key? registers name)
            (error (format "[machine] error: multiply define register ~a" name))
            (hash-set! registers name (register-new name))))
      (define (lookup-register name)
        (hash-ref registers name))
      (define (execute)
        (let ([insts (register-get pc)])
          (if (empty? insts)
              'done
              (begin
                ((instruction-execution-proc (car insts)))
                (execute)))))
      (define (dispatch msg)
        (cond [(eq? msg 'start)
               (register-set! pc instructions)
               (execute)]
              [(eq? msg 'install-instruction-sequence)
               (lambda (insts)
                 (set! instructions insts))]
              [(eq? msg 'install-operations)
               (lambda (ops)
                 (hash-union! operations ops))]
              [(eq? msg 'allocate-register) allocate-register]
              [(eq? msg 'lookup-register) lookup-register]
              [(eq? msg 'stack) stack]
              [(eq? msg 'operations) operations]
              [else (error (format "[machine] unknown message: ~a" msg))]))
      dispatch)))

(define (machine-start machine)
  (machine 'start))

(define (machine-get-register machine name)
  (register-get (get-register machine name)))

(define (machine-set-register! machine name value)
  (register-set! (get-register machine name) value))

(define (get-register machine name)
  ((machine 'lookup-register) name))
