#lang s-exp kernel

($define! constructed-pair
  ($let ((a 1)
         (b 2))
    (cons a b)))

(check-eq? (car constructed-pair) 1)
(check-eq? (cdr constructed-pair) 2)
