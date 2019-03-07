#lang s-exp kernel

($sequence
  ($define! a 1)
  ($define! b 2))

(check-eq? a 1)
(check-eq? b 2)

($define! basic-if
  ($cond
   (#f 1)
   (#t 2)))

(check-eq? basic-if 2)

($define! compound-predicates
  ($cond
   ((eq? 1 2) 3)
   ((eq? 4 5) 6)
   ((eq? 7 7) 8)))

(check-eq? compound-predicates 8)

($define! multiple-body-expressions
  ($cond
   (#t
    ($define! a 1)
    a)))

(check-eq? multiple-body-expressions 1)
