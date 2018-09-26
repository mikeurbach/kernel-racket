#lang br

(require "struct.rkt" "expr.rkt")
(provide b-rem b-print b-let b-input b-import b-export b-repl)

(define (b-rem val) (void))

(define (b-print . vals)
  (displayln (string-append* (map ~a vals))))

(define-macro (b-let ID VAL) #'(set! ID VAL))

(define-macro (b-input ID)
  #'(b-let ID (let* ([str (read-line)]
                     [num (string->number (string-trim str))])
                (or num str))))

(define-macro (b-import _) #'(void))

(define-macro (b-export _) #'(void))

(define-macro (b-repl . ALL-INPUTS)
  (with-pattern
    ([INPUTS (pattern-case-filter #'ALL-INPUTS
               [(b-print . ARGS)
                #'(b-print . ARGS)]
               [(b-expr . ARGS)
                #'(b-print (b-expr . ARGS))]
               [(b-let ID VAL)
                #'(define ID VAL)]
               [(b-def ID ARG ... BODY)
                #'(define (ID ARG ...) BODY)]
               [ANYTHING-ELSE
                #'(b-print "invalid repl input")])])
    #'(begin . INPUTS)))
