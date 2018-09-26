#lang br/quicklang

(require jsonic/tokenizer jsonic/parser racket/contract)

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (define jsonic-module `(module jsonic-module jsonic/expander
                         ,parse-tree))
  (datum->syntax #f jsonic-module))
(provide (contract-out
          [read-syntax (any/c input-port? . -> . syntax?)]))
