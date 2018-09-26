#lang br/quicklang

(define-macro (bf-module-begin PARSE-TREE)
  #'(#%module-begin
     PARSE-TREE))
(provide (rename-out [bf-module-begin #%module-begin]))

(define (fold-funcs apl bf-funcs)
  (for/fold ([current-apl apl])
            ([bf-func (in-list bf-funcs)])
    (apply bf-func current-apl)))

(define-macro (bf-program OP-OR-LOOP-ARG ...)
  #'(begin
      (define apl (list (make-vector 30000) 0))
      (void (fold-funcs apl (list OP-OR-LOOP-ARG ...)))))
(provide bf-program)

(define-macro (bf-loop "[" OP-OR-LOOP-ARG ... "]")
  #'(lambda (tape ptr)
      (for/fold ([current-apl (list tape ptr)])
                ([i (in-naturals)]
                 #:break (zero? (apply current-byte current-apl)))
        (fold-funcs current-apl (list OP-OR-LOOP-ARG ...)))))
(provide bf-loop)

(define-macro-cases bf-op
  [(bf-op "<") #'lt]
  [(bf-op ">") #'gt]
  [(bf-op "+") #'plus]
  [(bf-op "-") #'minus]
  [(bf-op ".") #'period]
  [(bf-op ",") #'comma])
(provide bf-op)

(define (current-byte tape ptr) (vector-ref tape ptr))
(define (set-current-byte tape ptr val)
  (define new-tape (vector-copy tape))
  (vector-set! new-tape ptr val)
  new-tape)
(define (lt tape ptr) (list tape (sub1 ptr)))
(define (gt tape ptr) (list tape (add1 ptr)))
(define (plus tape ptr)
  (list
   (set-current-byte tape ptr (add1 (current-byte tape ptr)))
   ptr))
(define (minus tape ptr)
  (list
   (set-current-byte tape ptr (sub1 (current-byte tape ptr)))
   ptr))
(define (period tape ptr)
  (write-byte (current-byte tape ptr))
  (list tape ptr))
(define (comma tape ptr)
  (list (set-current-byte tape ptr (read-byte)) ptr))
