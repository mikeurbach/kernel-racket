#lang br

(require "struct.rkt")
(provide b-line raise-line-err)

(define-macro (b-line NUM STATEMENT ...)
  (with-pattern ([LINE-NUM (prefix-id "line-" #'NUM #:source #'NUM)])
    (syntax/loc caller-stx
      (define (LINE-NUM #:error [msg #f])
        (with-handlers
          ([line-error?
            (lambda (line-err) (handle-line-err NUM line-err))])
          (when msg (raise-line-err msg))
          STATEMENT ...)))))

(define (handle-line-err line-num line-err)
  (error (format "error in line ~a: ~a" line-num (line-error-msg line-err))))

(define (raise-line-err msg)
  (raise (line-error msg)))
