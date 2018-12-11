#lang nanopass

(define-language Lsrc
  (terminals
   (number (n))
   (operator (op)))
  (Expr (e)
        n
        (op e0 e1)))

(define (operator? e)
  (memq e '(+ - *)))

(define-pass ast-to-Lsrc : * (ast) -> Lsrc ()
  (pass : * (e) -> Expr ()
         (cond
           [(number? e) e]
           [(and (list? e) (= 3 (length e)))
            (let ([op (car e)]
                  [e0 (pass (cadr e))]
                  [e1 (pass (caddr e))])
              `(,op ,e0 ,e1))]))
  (pass ast))

(define-language L1
  (extends Lsrc)
  (terminals
   (- (number (n)))
   (+ (variable (v))))
  (Expr (e)
        (- n)
        (+ v)
        (+ (lambda (v) e))
        (+ (apply e0 e1))))

(define (variable? e)
  (and (symbol? e) (not (operator? e))))

(define-pass encode-numbers : Lsrc (ast) -> L1 ()
  (pass : Expr (e) -> Expr ()
        [,n
         (letrec ([go (lambda (n) (if (= n 0) `x `(apply f ,(go (- n 1)))))])
           `(lambda (f) (lambda (x) ,(go n))))]))

(define-language L2
  (extends L1)
  (Expr (e)
        (- (op e0 e1))
        (+ op)))

(define-pass curry-operators : L1 (ast) -> L2 ()
  (pass : Expr (e) -> Expr ()
        [(,op ,[e0] ,[e1])
         `(apply (apply ,op ,e0) ,e1)]))

(define-language L3
  (extends L2)
  (terminals
   (- (operator (op))))
  (Expr (e)
        (- op)))

(define-pass encode-operators : L2 (ast) -> L3 ()
  (definitions
    (with-output-language (L3 Expr)
      (define add
        `(lambda (m) (lambda (n) (lambda (f) (lambda (x)
            (apply (apply m f) (apply (apply n f) x)))))))
      (define pred
        `(lambda (n) (lambda (f) (lambda (x)
           (apply
            (apply
             (apply n (lambda (g) (lambda (h) (apply h (apply g f)))))
             (lambda (u) x))
            (lambda (u) u))))))
      (define subtract
        `(apply
          (lambda (pred)
            (lambda (m) (lambda (n) (apply (apply n pred) m))))
          ,pred))
      (define multiply
        `(lambda (m) (lambda (n) (lambda (f)
           (apply m (apply n f))))))))
  (pass : Expr (e) -> Expr ()
        [,op
         (case op
           ['+ add]
           ['- subtract]
           ['* multiply])]))

(define-pass output-racket : L3 (ast) -> * ()
  (pass : Expr (e) -> * ()
        [,v v]
        [(apply ,[pass : e0] ,[pass : e1]) `(,e0 ,e1)]
        [(lambda (,v) ,[pass : e]) `(lambda (,v) ,e)]))

(define (encode e)
  ((compose1
    output-racket
    encode-operators
    curry-operators
    encode-numbers
    ast-to-Lsrc)
   e))

(define (to-church e)
  ((compose1
    eval
    encode)
   e))

(define (from-church n)
  ((n (lambda (m) (+ 1 m))) 0))

(define (repl)
  (display "church> ")
  (let ([e (read)])
    (cond
      [(eq? e eof) (newline)]
      [else
       (begin
         (display "ENCODED: ")
         (displayln (encode e))
         (display "RESULT: ")
         (displayln (from-church (to-church e)))
         (repl))])))

(repl)
