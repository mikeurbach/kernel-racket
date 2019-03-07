#lang s-exp kernel

(check-equal? (list 1 2 3) (cons 1 (cons 2 (cons 3 ()))))

(check-eq? (list* 1) 1)
(check-equal? (list* 1 2) (cons 1 2))
(check-equal? (list* 1 2 3) (cons 1 (cons 2 3)))
(check-equal? (list* 1 2 3 ()) (cons 1 (cons 2 (cons 3 ()))))
