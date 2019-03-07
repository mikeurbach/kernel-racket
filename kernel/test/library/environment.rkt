#lang s-exp kernel

($define! constructed-pair
  ($let ((a 1)
         (b 2))
    (cons a b)))

(check-equal? constructed-pair (cons 1 2))
