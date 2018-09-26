#lang br/quicklang

(require "struct.rkt" "elements.rkt" "run.rkt" "setup.rkt")
(provide (rename-out [b-module-begin #%module-begin])
         (all-from-out "elements.rkt"))

(define-macro (b-module-begin (b-program LINE ...))
  (with-pattern
    ([((b-line NUM STATEMENT ...) ...) #'(LINE ...)]
     [(LINE-FUNC ...) (prefix-id "line-" #'(NUM ...))]
     [(VAR-ID ...) (find-property 'b-id #'(LINE ...))]
     [(IMPORT-NAME ...) (find-property 'b-import-name #'(LINE ...))]
     [(EXPORT-NAME ...) (find-property 'b-export-name #'(LINE ...))]
     [((SHELL-ID SHELL-IDX) ...) (make-shell-ids-and-idxs caller-stx)]
     [(UNIQUE-ID ...) (unique-ids (syntax->list #'(VAR-ID ... SHELL-ID ...)))])
    #'(#%module-begin
       (module configure-runtime br
         (require basic/setup)
         (do-setup!))
       (require IMPORT-NAME ...)
       (provide EXPORT-NAME ...)
       (define UNIQUE-ID 0) ...
       (let ([clargs (current-command-line-arguments)])
         (set! SHELL-ID (get-clarg clargs SHELL-IDX)) ...)
       LINE ...
       (define line-table
         (apply hasheqv (append (list NUM LINE-FUNC) ...)))
       (parameterize ([current-output-port (basic-output-port)])
         (void (run line-table))))))

(begin-for-syntax
  (require racket/list)

  (define (make-shell-ids-and-idxs ctxt)
    (define arg-count 10)
    (for/list ([idx (in-range arg-count)])
      (list (suffix-id #'arg idx #:context ctxt) idx)))

  (define (unique-ids stxs)
    (remove-duplicates stxs #:key syntax->datum))

  (define (find-property which line-stxs)
    (unique-ids
     (for/list ([stx (in-list (stx-flatten line-stxs))]
                #:when (syntax-property stx which))
       stx))))

(define (get-clarg clargs idx)
  (if (<= (vector-length clargs) idx)
      0
      (let ([val (vector-ref clargs idx)])
        (or (string->number val) val))))
