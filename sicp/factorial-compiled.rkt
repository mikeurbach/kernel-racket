#lang reader "compiler.rkt"

(begin
  (define (factorial n)
    (if (= n 1)
        1
        (* (factorial (- n 1)) n)))
  (factorial 1000))

;; (machine-start machine)
;; (machine-get-register machine 'val)
