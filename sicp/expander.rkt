#lang racket

; 1. collect register names
;   a. first operand of assign instruction
;   b. operand of save instruction
;   c. operand of restore instruction
;   d. (reg ...) forms in an instruction
; 2. install racket functions
; 3. assemble program and make the machine

(require racket/hash "primitives.rkt")
(provide (except-out (all-from-out racket) #%module-begin)
         (rename-out [module-begin #%module-begin]))

(define-syntax-rule (module-begin (controller instruction ...))
  (#%module-begin
   (require "machine.rkt")
   (provide machine (all-from-out "machine.rkt"))
   (define machine
     (make-machine
      (unique-registers
       (list
        (extract-registers 'instruction)
        ...))
      (unique-operations
       (list
        (extract-operations 'instruction)
        ...))
      '(controller instruction ...)))))

(define (unique-registers register-lists)
  (remove-duplicates
   (foldl append '() register-lists)))

(define (extract-registers instruction)
  (cond [(symbol? instruction) '()]
        [(eq? (car instruction) 'assign) (list (cadr instruction))]
        [(eq? (car instruction) 'save) (list (cadr instruction))]
        [(eq? (car instruction) 'restore) (list (cadr instruction))]
        [(list? instruction) (extract-register-exprs instruction)]
        [else '()]))

(define (extract-register-exprs instruction)
  ((compose1 register-names register-exprs) instruction))

(define (register-exprs instruction)
  (filter-tagged-list instruction 'reg))

(define (register-names register-exprs)
  (foldl
   (lambda (e a)
     (cons (cadr e) a))
   '()
   register-exprs))

(define (unique-hash-union h1 h2)
  (hash-union h1 h2 #:combine/key (lambda (k v1 v2) v2)))

(define (unique-operations operation-lists)
  (foldl unique-hash-union (hasheq) operation-lists))

(define (extract-operations instruction)
  (cond [(symbol? instruction) (hasheq)]
        [(list? instruction) (extract-operation-exprs instruction)]
        [else (hasheq)]))

(define (extract-operation-exprs instruction)
  ((compose1 operations operation-exprs) instruction))

(define (operation-exprs instruction)
  (filter-tagged-list instruction 'op))

(define (operations operation-exprs)
  (foldl
   (lambda (e a)
     (hash-union
      (hasheq (cadr e) (operation-procedure (cadr e)))
      a))
   (hasheq)
   operation-exprs))

(define (operation-procedure name)
  (parameterize ([current-namespace (make-base-empty-namespace)])
    (namespace-require 'racket)
    (namespace-require (quote "primitives.rkt"))
    (eval name)))

(define (filter-tagged-list exprs symbol)
  (filter
   (lambda (expr)
     (and (list? expr) (eq? (car expr) symbol)))
   exprs))
