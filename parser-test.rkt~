#lang br

(require "parser.rkt")

(module+ test
  (require rackunit)
  (check-equal? (parse-to-datum "++++-+++-++-++")
                '(bf-program
                  (bf-op "+")
                  (bf-op "+")
                  (bf-op "+")
                  (bf-op "+")
                  (bf-op "-")
                  (bf-op "+")
                  (bf-op "+")
                  (bf-op "+")
                  (bf-op "-")
                  (bf-op "+")
                  (bf-op "+")
                  (bf-op "-")
                  (bf-op "+")
                  (bf-op "+"))))
