#lang racket

(require "symbol.rkt" "pair.rkt" rackunit)

(provide environment? kernel-ignore? make-environment show-environment match! bind! lookup)

(struct environment (locals parents))
(struct not-found ())

(define (kernel-ignore? object)
  (eqv? object '|#ignore|))

(define (make-environment parents)
  (environment (make-hasheqv) parents))

(define (match! ptree expr env)
  ;; (displayln (format "match!: ptree = ~v, expr = ~v" ptree expr))
  (cond [(kernel-ignore? ptree) '|#ignore|]
        [(kernel-symbol? ptree) (bind! env ptree expr)]
        [(kernel-null? ptree)
         (when (not (kernel-null? expr))
           (error '$match "ptree is nil but expr is ~v" expr))]
        [(kernel-pair? ptree)
         (if (not (kernel-pair? expr))
             (error '$match "ptree is a pair but expr is ~v" expr)
             (begin
               (match! (car ptree) (car expr) env)
               (match! (cdr ptree) (cdr expr) env)))]
        [#t (error '$match "unable to match ~v" ptree)]))

(define (bind! env symbol value)
  (hash-set! (environment-locals env) symbol value))

(define (lookup symbol env)
  (let ([result (lookup-helper symbol env)])
    (if (not-found? result)
        (error 'lookup "symbol ~v not found" symbol)
        result)))

(define (lookup-helper symbol env)
  (hash-ref (environment-locals env) symbol
            (lambda ()
              (let ([parents (environment-parents env)])
                ;; (displayln (format "lookup-helper: symbol = ~v, env = ~v, parents = ~v" symbol env parents))
                (if (empty? parents)
                    (not-found)
                    (lookup-in-parents symbol parents))))))

(define (lookup-in-parents symbol parents)
  (let ([parent-results
         (map
          (lambda (env) (lookup-helper symbol env))
          parents)])
    (if (andmap not-found? parent-results)
        (not-found)
        (findf (lambda (result)
                 (not (not-found? result)))
               parent-results))))

(define (show-environment env)
  (for ([key (hash-keys (environment-locals env))])
    (displayln (format "~v: ~v" key (hash-ref (environment-locals env) key))))
  (for ([parent (environment-parents env)])
    (show-environment parent)))

(test-begin
  (letrec ([blank (environment (hasheqv) '())]
           [locals (environment (hasheqv 'a 420) '())]
           [parents (environment (hasheqv) (list locals))]
           [override-parents (environment (hasheqv 'a 69) (list locals))]
           [grandchild (environment (hasheqv) (list parents))]
           [two-parents (environment (hasheqv) (list blank locals))])
    (check-exn exn:fail? (lambda () (lookup 'a blank)))
    (check-eq? (lookup 'a locals) 420)
    (check-eq? (lookup 'a parents) 420)
    (check-eq? (lookup 'a override-parents) 69)
    (check-eq? (lookup 'a grandchild) 420)
    (check-eq? (lookup 'a two-parents) 420)))
