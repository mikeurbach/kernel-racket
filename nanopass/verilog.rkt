#lang nanopass

(require "module-printer.rkt")

(define-language module-specification
  (terminals
   (identifier (identifier))
   (symbol (symbol))
   (port-type (port-type))
   (size (size)))
  (Expr (e)
        symbol
        (mod identifier (e0 ...) (e1 ...))
        ;; (symbol (e0 ...) e1)
        (input identifier size)
        (output identifier size)))

(define identifier? string?)
(define port-type? string?)
(define (size? e)
  (or
   (empty? e)
   (and
    (pair? e)
    (number? (car e))
    (number? (cdr e)))))

(define-pass output-module : module-specification (ast) -> * ()
  (definitions
    (define (module-writer name operations ports)
      (new module-printer
           [operations operations]
           [name name]
           [ports ports])))
           ;; [states states])))
  (pass : Expr (e) -> * ()
        [,symbol symbol]
        [(mod ,identifier
              (,[pass : operations] ...)
              (,[pass : ports] ...))
              ;; (,[pass : states] ...))
         (display
          (send (module-writer
                 identifier
                 operations
                 ports) print))]
        ;; [(,symbol (,[pass : assigns] ...) ,[pass : next_state]) (list symbol assigns next_state)]
        [(input ,identifier ,size) (list 'input identifier size)]
        [(output ,identifier ,size) (list 'output identifier size)]))

(begin
  (define-parser mod-parser module-specification)
  (output-module
   (mod-parser
    '(mod "pair"
          (new car cdr set_car set_cdr)
          ((input "car" (8 . 0))
           (input "cdr" (8 . 0))
           (input "ref_in" (8 . 0))
           (output "ref_out" (8 . 0)))))))
          ;; ((start
          ;;   (a b c)
          ;;   done)
          ;;  (done
          ;;   ()
          ;;   eof))))))

;; brainstorm:
;; (mod pair
;;      (op new
;;          ((input car (8 . 0))
;;           (input cdr (8 . 0))
;;           (output pair_out (8 . 0)))
;;          (new-start
;;           (((reg next_addr) (op +) (reg next_addr) (const 1'd1))
;;            ((reg pair_out) (op concat) (const 1'b1) (reg next_addr))
;;            ((mem cars (reg next_addr)) (reg car))
;;            ((mem cdrs (reg next_addr)) (reg cdr))))
;;          init))
