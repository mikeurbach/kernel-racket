#lang br/quicklang

(define (read-syntax path port)
  (define src-lines (port->lines port))
  (define arg-list (format-datums '~a src-lines))
  (define module-datum `(module funstacker-mod "funstacker.rkt"
                          (handle-args ,@arg-list)))
  (datum->syntax #f module-datum))
(provide read-syntax)

(define-macro (stacker-module-begin EXPR)
  #'(#%module-begin
     (display (first EXPR))))
(provide (rename-out [stacker-module-begin #%module-begin]))

(define (handle-args . args)
  (for/fold ([acc empty])
            ([arg (filter-not void? args)])
    (cond [(number? arg) (cons arg acc)]
          [(or (equal? arg +) (equal? arg *))
           (define result (arg (first acc) (second acc)))
           (cons result (drop acc 2))])))
(provide handle-args)
