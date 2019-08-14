#lang s-exp kernel

($define! gcd
  ($lambda (a b)
    ($if (eq? b 0)
      a
      (gcd b (remainder a b)))))
(gcd 21 9)
