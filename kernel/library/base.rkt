#lang s-exp kernel/core

;; 5.1 Control
($define! $sequence
  ((wrap
     ($vau ($seq2) |#ignore|
       ($seq2
        ($define! $aux
          ($vau (head . tail) env
            ($if (null? tail)
              (eval head env)
              ($seq2
               (eval head env)
               (eval (cons $aux tail) env)))))
        ($vau body env
          ($if (null? body)
            |#inert|
            (eval (cons $aux body) env))))))
   ($vau (first second) env
     ((wrap ($vau |#ignore| |#ignore| (eval second env)))
      (eval first env)))))

;; 5.2 Pairs and Lists
($define! list
  (wrap
    ($vau args |#ignore| args)))

($define! list*
  (wrap
    ($vau args |#ignore|
      ($sequence
        ($define! aux
          (wrap
            ($vau ((head . tail)) |#ignore|
              ($if (null? tail)
                head
                (cons head (aux tail))))))
        (aux args)))))
