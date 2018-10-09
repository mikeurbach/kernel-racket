#lang racket

(require rnrs/mutable-pairs-6 "register.rkt" "stack.rkt")
(provide assemble instruction-execution-proc)

(define (assemble controller-text machine)
  (extract-labels
   controller-text
   (lambda (insts labels)
     (update-insts! insts labels machine)
     insts)))

(define (extract-labels text continuation)
  (if (empty? text)
      (continuation '() (make-immutable-hasheq))
      (extract-labels
       (cdr text)
       (lambda (insts labels)
         (let ([next-inst (car text)])
           (if (symbol? next-inst)
               (continuation insts (hash-set labels next-inst insts))
               (continuation (cons (make-instruction next-inst) insts) labels)))))))

(define (update-insts! insts labels machine)
  (let ([pc ((machine 'lookup-register) 'pc)]
        [flag ((machine 'lookup-register) 'flag)]
        [stack (machine 'stack)]
        [ops (machine 'operations)])
    (for/list ([instruction insts])
      (set-instruction-execution-proc!
       instruction
       (make-execution-procedure
        (instruction-text instruction) labels machine pc flag stack ops)))
    insts))

(define (make-instruction text)
  (mcons text '()))

(define (instruction-text instruction)
  (mcar instruction))

(define (instruction-execution-proc instruction)
  (mcdr instruction))

(define (set-instruction-execution-proc! instruction proc)
  (set-mcdr! instruction proc))

(define (make-execution-procedure instruction labels machine pc flag stack ops)
  (cond [(eq? (car instruction) 'assign)
         (make-assign instruction machine labels ops pc)]
        [(eq? (car instruction) 'test)
         (make-test instruction machine labels ops flag pc)]
        [(eq? (car instruction) 'branch)
         (make-branch instruction machine labels flag pc)]
        [(eq? (car instruction) 'goto)
         (make-goto instruction machine labels pc)]
        [(eq? (car instruction) 'save)
         (make-save instruction machine stack pc)]
        [(eq? (car instruction) 'restore)
         (make-restore instruction machine stack pc)]
        [(eq? (car instruction) 'perform)
         (make-restore instruction machine stack pc)]
        [else (error (format "[assemble] unknown instruction ~v" instruction))]))

(define (make-assign instruction machine labels operations pc)
  (let ([target ((machine 'lookup-register) (assign-reg-name instruction))]
        [value-exp (assign-value-exp instruction)])
    (let ([value-proc
           (if (operation-exp? value-exp)
               (make-operation-exp
                value-exp machine labels operations)
               (make-primitive-exp
                (car value-exp) machine labels))])
      (lambda ()
        (register-set! target (value-proc))
        (advance-pc pc)))))

(define (assign-reg-name instruction)
  (cadr instruction))

(define (assign-value-exp instruction)
  (cddr instruction))

(define (advance-pc pc)
  (register-set! pc (cdr (register-get pc))))

(define (make-test instruction machine labels operations flag pc)
  (let ([condition (test-condition instruction)])
    (if (operation-exp? condition)
        (let ([condition-proc
               (make-operation-exp
                condition machine labels operations)])
          (lambda ()
            (register-set! flag (condition-proc))
            (advance-pc pc)))
        (error (format "[assemble] bad test: ~v" instruction)))))

(define (test-condition instruction)
  (cdr instruction))

(define (make-branch instruction machine labels flag pc)
  (let ([destination (branch-destination instruction)])
    (if (label-exp? destination)
        (let ([insts (hash-ref labels (label-exp-label destination))])
          (lambda ()
            (if (register-get flag)
                (register-set! pc insts)
                (advance-pc pc))))
        (error (format "[assemble] bad branch: ~v" instruction)))))

(define (branch-destination instruction)
  (cadr instruction))

(define (make-goto instruction machine labels pc)
  (let ([destination (goto-destination instruction)])
    (cond [(label-exp? destination)
           (let ([insts (hash-ref labels (label-exp-label destination))])
             (lambda ()
               (register-set! pc insts)))]
          [(register-exp? destination)
           (let ([reg ((machine 'lookup-register) (register-exp-reg destination))])
             (lambda ()
               (register-set! pc (register-get reg))))]
          [else (error (format "[assemble] bad goto: ~v" instruction))])))

(define (goto-destination instruction)
  (cadr instruction))

(define (make-save instruction machine stack pc)
  (let ([reg ((machine 'lookup-register) (stack-inst-reg-name instruction))])
    (lambda ()
      (stack-push stack (register-get reg))
      (advance-pc pc))))

(define (make-restore instruction machine stack pc)
  (let ([reg ((machine 'lookup-register) (stack-inst-reg-name instruction))])
    (lambda ()
      (register-set! reg (stack-pop stack))
      (advance-pc pc))))

(define (stack-inst-reg-name instruction)
  (cadr instruction))

(define (make-perform instruction machine labels operations pc)
  (let ([action (perform-action instruction)])
    (if (operation-exp? action)
        (let ([action-proc (make-operation-exp action machine labels operations)])
          (lambda ()
            (action-proc)
            (advance-pc pc)))
        (error (format "[assemble] bad perform: ~v" instruction)))))

(define (perform-action instruction)
  (cdr instruction))

(define (make-primitive-exp expression machine labels)
  (cond [(constant-exp? expression)
         (let ([c (constant-exp-value expression)])
           (lambda () c))]
        [(label-exp? expression)
         (let ([insts (hash-ref labels (label-exp-label expression))])
           (lambda () insts))]
        [(register-exp? expression)
         (let ([reg ((machine 'lookup-register) (register-exp-reg expression))])
           (lambda () (register-get reg)))]
        [else (error (format "[assemble] unknown expression: ~v" expression))]))

(define (register-exp? expression)
  (tagged-list? expression 'reg))

(define (register-exp-reg expression)
  (cadr expression))

(define (constant-exp? expression)
  (tagged-list? expression 'const))

(define (constant-exp-value expression)
  (cadr expression))

(define (label-exp? expression)
  (tagged-list? expression 'label))

(define (label-exp-label expression)
  (cadr expression))

(define (tagged-list? list symbol)
  (eq? (car list) symbol))

(define (make-operation-exp expression machine labels operations)
  (let ([op (hash-ref operations (operation-exp-op expression))]
        [aprocs
         (map (lambda (e)
                (make-primitive-exp e machine labels))
              (operation-exp-operands expression))])
    (lambda ()
      (apply op (map (lambda (p) (p)) aprocs)))))

(define (operation-exp? expression)
  (and (pair? expression) (tagged-list? (car expression) 'op)))

(define (operation-exp-op operation-exp)
  (cadr (car operation-exp)))

(define (operation-exp-operands operation-exp)
  (cdr operation-exp))
