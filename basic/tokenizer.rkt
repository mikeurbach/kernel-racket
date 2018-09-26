#lang br

(require "lexer.rkt" brag/support)

(define (make-tokenizer input [path #f])
  (port-count-lines! input)
  (lexer-file-path path)
  (define (next-token) (basic-lexer input))
  next-token)

(provide make-tokenizer)
