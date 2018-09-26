#lang br/quicklang

(require "parser.rkt" "tokenizer.rkt")

(module+ reader
  (provide read-syntax get-info))

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module basic-mod basic/expander
       #,parse-tree)))

(define (get-info port mod line col pos)
  (define (handle-query key default)
    (case key
      [(color-lexer)
       (dynamic-require 'basic/colorer 'basic-colorer)]
      [else default]))
  handle-query)
