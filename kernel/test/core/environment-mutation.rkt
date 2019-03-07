#lang s-exp kernel/core

($define! a 1)
(check-eq? a 1)

($define! (b . c) (cons 420 69))
(check-eq? b 420)
(check-eq? c 69)

($define! (d e f) (cons 6 (cons 7 (cons 8 ()))))
(check-eq? d 6)
(check-eq? e 7)
(check-eq? f 8)
