#lang racket

(require "core.rkt")

(define (repl env)
  (display "kernel/core> ")
  (write (kernel-eval (read) env))
  (newline)
  (repl env))

(repl (make-ground-environment))
