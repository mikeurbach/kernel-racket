#lang nanopass

(provide verilog output-verilog)

(define (size? e)
  (and (pair? e)
       (number? (car e))
       (number? (cdr e))))

(define unary-ops
  (set '+ '- '! '~))

(define (unary-op? e)
  (set-member? unary-ops e))

(define binary-ops
  (set '+ '- '* '/ '% '< '<= '> '>= '&& '\|\| '== '!= '& '\| '^ '~^ '^~ '& '~& '~\| '<< '>>))

(define (binary-op? e)
  (set-member? binary-ops e))

(define-language verilog
  (entry Assign)
  (terminals
   (symbol (symbol))
   (size (size))
   (unary-op (unop))
   (binary-op (binop)))
  (Register (register)
    (reg symbol)
    (reg symbol size))
  (Input (input)
    (in symbol)
    (in symbol size))
  (Output (output)
    (out symbol)
    (out symbol size))
  (MemoryRef (memory-ref)
    register
    input)
  (Memory (memory)
    (mem symbol memory-ref))
  (AssignTarget (assign-target)
    register
    memory
    output)
  (AssignValue (assign-value)
    register
    memory
    input)
  (UnaryOp (unary-op)
    (op unop))
  (BinaryOp (binary-op)
    (op binop))
  (Assign (assign)
    (assign-target assign-value)
    (assign-target unary-op assign-value)
    (assign-target binary-op assign-value1 assign-value2)))

(define-pass output-verilog : verilog (ast) -> * ()
  (register-pass : Register (r) -> * ()
    [(reg ,symbol) (list 'reg symbol)]
    [(reg ,symbol ,size) (list 'reg symbol size)])
  (input-pass : Input (i) -> * ()
    [(in ,symbol) (list 'in symbol)]
    [(in ,symbol ,size) (list 'in symbol size)])
  (output-pass : Output (i) -> * ()
    [(out ,symbol) (list 'out symbol)]
    [(out ,symbol ,size) (list 'out symbol size)])
  (memory-ref-pass : MemoryRef (mr) -> * ())
  (memory-pass : Memory (m) -> * ()
    [(mem ,symbol ,[memory-ref-pass : memory-ref]) (list 'mem symbol memory-ref)])
  (assign-target-pass : AssignTarget (at) -> * ())
  (assign-value-pass : AssignValue (av) -> * ())
  (unary-op-pass : UnaryOp (uo) -> * ()
    [(op ,unop) (list 'op unop)])
  (binary-op-pass : BinaryOp (bo) -> * ()
    [(op ,binop) (list 'op binop)])
  (assign-pass : Assign (a) -> * ()
    [(,[assign-target-pass : assign-target] ,[assign-value-pass : assign-value]) (list assign-target assign-value)]
    [(,[assign-target-pass : assign-target] ,[unary-op-pass : unary-op] ,[assign-value-pass : assign-value]) (list assign-target unary-op assign-value)]
    [(,[assign-target-pass : assign-target] ,[binary-op-pass : binary-op] ,[assign-value-pass : assign-value1] ,[assign-value-pass : assign-value2]) (list assign-target binary-op assign-value1 assign-value2)]))

;; brainstorm:
;; (pair
;;  ((mem cars (8 . 0) (255 . 0))
;;   (mem cdrs (8 . 0) (255 . 0))
;;   (reg next_addr (8 . 0) (const 1'd1)))
;;  (cons ((input car (8 . 0))
;;         (input cdr (8 . 0))
;;         (output pair_out (8 . 0)))
;;        ((store-cons
;;          (((mem cars) (reg next_addr) (reg car))
;;           ((mem cdrs) (reg next_addr) (reg cdr))
;;           ((reg next_addr) (op +) (reg next_addr) (const 1'd1))
;;           ((output ref_out) (op ,) (const 1'b1) (reg next_addr))))))
;;  (car ((input pair_in (8 . 0))
;;        (output pair_out (8 . 0)))
;;       ((load-car
;;         (((output pair_out) (mem cars) (input pair_in (7 . 0)))))))
;;  (cdr ((input pair_in (8 . 0))
;;        (output pair_out (8 . 0)))
;;       ((load-cdr
;;         (((output pair_out) (mem cdrs) (input pair_in (7 . 0)))))))
;;  (set_car ((input pair_in (8 . 0))
;;            (input car (8 . 0)))
;;           ((store-car
;;             (((mem cars) (input pair_in (7 . 0)) (input car))))))
;;  (set_cdr ((input pair_in (8 . 0))
;;            (input cdr (8 . 0)))
;;           ((store-cdr
;;             (((mem cdrs) (input pair_in (7 . 0)) (input cdr)))))))
