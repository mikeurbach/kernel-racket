#lang br/quicklang

(require json)

(define-macro (jsonic-module-begin PARSE-TREE)
  #'(#%module-begin
     (define result PARSE-TREE)
     (define _valid (string->jsexpr result))
     (display result)))
(provide (rename-out [jsonic-module-begin #%module-begin]))

(define-macro (jsonic-program SEXP-OR-CHAR ...)
  #'(string-trim (string-append SEXP-OR-CHAR ...)))
(provide jsonic-program)

(define-macro (jsonic-sexp SEXP-STRING)
  (with-pattern ([SEXP-DATUM (format-datum '~a #'SEXP-STRING)])
    #'(jsexpr->string SEXP-DATUM)))
(provide jsonic-sexp)

(define-macro (jsonic-char CHAR-TOKEN)
  #'CHAR-TOKEN)
(provide jsonic-char)
