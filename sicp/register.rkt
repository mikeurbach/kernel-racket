#lang racket

(provide register-new register-get register-set!)

(define (register-new name)
  (let ([value #f])
    (define (dispatch msg)
      (cond [(eq? msg 'get) value]
            [(eq? msg 'set)
             (lambda (val)
               (set! value val))]
            [else
             (error (format "[register] unknown message: ~a" msg))]))
    dispatch))

(define (register-get register)
  (register 'get))

(define (register-set! register value)
  ((register 'set) value))
