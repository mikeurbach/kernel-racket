#lang br/quicklang

(module+ reader
  (provide read-syntax))

(define (read-syntax path port)
  (define wire-data
    (for/list ([wire-str (in-lines port)])
      (format-datum '(wire ~a) wire-str)))
  (strip-bindings
   #`(module wire-mod wires/main
       #,@wire-data)))

(provide #%module-begin)

(define-macro-cases wire
  [(wire ARG -> ID)
   #'(define/display (ID) (val ARG))]
  [(wire OP ARG -> ID)
   #'(wire (OP (val ARG)) -> ID)]
  [(wire ARG1 OP ARG2 -> ID)
   #'(wire (OP (val ARG1) (val ARG2)) -> ID)]
  [else #'(void)])
(provide wire)

(define-macro
  (define/display (ID) BODY)
  #'(begin
      (define (ID) BODY)
      (module+ main
        (displayln (format "~a: ~a" 'ID (ID))))))

(define val
  (let ([cache (make-hash)])
    (lambda (num-or-wire)
      (if (number? num-or-wire)
          num-or-wire
          (hash-ref! cache num-or-wire num-or-wire)))))

(define (mod16 x) (modulo x 65536))
(define-macro (define16 ID PROC)
  #'(define ID (compose1 mod16 PROC)))

(define16 AND bitwise-and)
(define16 OR bitwise-ior)
(define16 NOT bitwise-not)
(define16 LSHIFT arithmetic-shift)
(define (RSHIFT a b) (LSHIFT a (- b)))
(provide AND OR NOT LSHIFT RSHIFT)
