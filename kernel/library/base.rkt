#lang s-exp kernel/core

;; 5.1 Control
($define! $sequence
  ((wrap ($vau ($seq2) |#ignore|
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
  (wrap ($vau args |#ignore| args)))

($define! list*
  (wrap ($vau args |#ignore|
          ($sequence
            ($define! aux
              (wrap ($vau ((head . tail)) |#ignore|
                      ($if (null? tail)
                        head
                        (cons head (aux tail))))))
            (aux args)))))

;; 5.3 Combiners
($define! $vau
  ((wrap ($vau ($core-vau) |#ignore|
           ($core-vau (formals eformal . body) env
             (eval (list $core-vau formals eformal
                         (cons $sequence body))
                   env))))
   $vau))

($define! $lambda
  ($vau (formals . body) env
    (wrap (eval (list* $vau formals |#ignore| body)
                env))))

;; 5.4 Pairs and Lists
($define! car ($lambda ((object . |#ignore|)) object))
($define! cdr ($lambda ((|#ignore| . object)) object))

;; 5.5 Combiners
($define! apply
  ($lambda (applicative arg . opt)
    (eval (cons (unwrap applicative) arg)
          ($if (null? opt)
            (make-environment ())
            (car opt)))))

($define! map
  (wrap ($vau (applicative . lists) env
          ($if (null? lists)
            (displayln "error: map was not supplied lists")
            (cons (apply applicative (list (car lists)) env)
                ($if (null? (cdr lists))
                  ()
                  (apply map (cons applicative (cdr lists)) env)))))))
