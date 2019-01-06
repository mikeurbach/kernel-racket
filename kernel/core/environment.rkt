#lang racket

(require "symbol.rkt" "pair.rkt" rackunit)

(provide environment? kernel-ignore? make-environment match! bind! lookup)

(struct environment (locals parents))
(struct not-found ())

(define (kernel-ignore? object)
  (eqv? object '|#ignore|))

(define (make-environment parents)
  (environment (make-hasheqv) parents))

(define (match! ptree expr env)
  (cond [(kernel-symbol? ptree) (bind! env ptree expr)]
        [(kernel-ignore? ptree) '|#ignore|]
        [(kernel-null? ptree)
         (when (not (kernel-null? expr))
           (error '$match "ptree is nil but expr is ~v" expr))]
        [(kernel-pair? ptree)
         (if (not (kernel-pair? expr))
             (error '$match "ptree is a pair but expr is ~v" expr)
             (begin
               (match! (mcar ptree) (mcar expr) env)
               (match! (mcdr ptree) (mcdr expr) env)))]
        [#t (error '$match "unable to match ~v" ptree)]))

(define (bind! environment symbol value)
  (hash-set! (environment-locals environment) symbol value))

(define (lookup symbol env)
  (let ([result (lookup-helper symbol env)])
    (if (not-found? result)
        (error 'lookup "symbol ~v not found" symbol)
        result)))

(define (lookup-helper symbol env)
  (hash-ref (environment-locals env) symbol
            (lambda ()
              (let ([parents (environment-parents env)])
                (if (empty? parents)
                    (not-found)
                    (lookup-in-parents symbol parents))))))

(define (lookup-in-parents symbol parents)
  (let ([parent-results
         (map
          (lambda (env) (lookup-helper symbol env))
          parents)])
    (findf (lambda (result)
             (not (not-found? result)))
           parent-results)))

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
