#lang br

(require "struct.rkt" "line.rkt" "misc.rkt")
(provide b-end b-goto b-gosub b-return b-for b-next)

(define (b-end) (raise (end-program-signal)))

(define (b-goto expr) (raise (change-line-signal expr)))

(define return-ccs empty)

(define (b-gosub expr)
  (let/cc cc
    (push! return-ccs cc)
    (b-goto expr)))

(define (b-return)
  (when (empty? return-ccs)
    (raise-line-err "return without gosub"))
  (define cc (pop! return-ccs))
  (cc (void)))

(define next-funcs (make-hasheq))

(define (in-closed-interval? x start end)
    ((if (< start end) <= >=) start x end))

(define-macro-cases b-for
  [(_ LOOP-ID START END) #'(b-for LOOP-ID START END 1)]
  [(_ LOOP-ID START END STEP)
   #'(b-let LOOP-ID (let/cc loop-cc
                      (hash-set! next-funcs
                                 'LOOP-ID
                                 (lambda ()
                                   (define next-val
                                     (+ LOOP-ID STEP))
                                   (if (next-val . in-closed-interval? . START END)
                                       (loop-cc next-val)
                                       (hash-remove! next-funcs 'LOOP-ID))))
                      START))])

(define-macro (b-next LOOP-ID)
  #'(begin
      (unless (hash-has-key? next-funcs 'LOOP-ID)
        (raise-line-err
         (format "`next ~a` without for" 'LOOP-ID)))
      (define fn (hash-ref next-funcs 'LOOP-ID))
      (fn)))
