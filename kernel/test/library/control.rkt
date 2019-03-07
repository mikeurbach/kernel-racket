#lang s-exp kernel

($sequence
  ($define! a 1)
  ($define! b 2))

(check-eq? a 1)
(check-eq? b 2)
