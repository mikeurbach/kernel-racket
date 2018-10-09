#lang racket

(provide stack-new stack-initialize stack-push stack-pop)

(define (stack-new)
  (let ([stack '()])
    (define (initialize)
      (set! stack '()))
    (define (push value)
      (set! stack (cons value stack)))
    (define (pop)
      (if (empty? stack)
          (error "[stack] error: empty stack")
          (begin
            (let ([val (car stack)])
              (set! stack (cdr stack))
              val))))
    (define (dispatch msg)
      (cond [(eq? msg 'initialize) (initialize)]
            [(eq? msg 'push) (lambda (value) (push value))]
            [(eq? msg 'pop) (pop)]
            [else
             (error (format "[stack] unknown message: ~a" msg))]))
    dispatch))

(define (stack-initialize stack)
  (stack 'initialize))

(define (stack-push stack value)
  ((stack 'push) value))

(define (stack-pop stack)
  (stack 'pop))
