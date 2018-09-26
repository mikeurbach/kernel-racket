#lang br

(require "parser.rkt" "tokenizer.rkt")
(provide basic-output-port do-setup!)

(define basic-output-port
  (make-parameter (open-output-nowhere)))

(define repl-parse (make-rule-parser b-repl))

(define (read-one-line origin port)
  (define line (read-line port))
  (if (eof-object? line)
      eof
      (repl-parse
       (make-tokenizer (open-input-string line)))))

(define (do-setup!)
  (basic-output-port (current-output-port))
  (current-read-interaction read-one-line))
