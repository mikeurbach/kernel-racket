#lang nanopass

(provide rtl-adt adt-to-fsm)

(define (size? e)
  (and (pair? e)
       (number? (car e))
       (number? (cdr e))))

(define bitwidth? number?)

(define baseidents
  (set 'b 'o 'h 'd))

(define (baseident? e)
  (set-member? baseidents e))

(define hexchars
  (set #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\a #\b #\c #\d #\e #\f))

(define (literal? e)
  (or (number? e)
      (and (symbol? e)
           (andmap (lambda (c) (set-member? hexchars c))
                   (string->list (symbol->string e))))))

(define unary-ops
  (set '+ '- '! '~))

(define (unary-op? e)
  (set-member? unary-ops e))

(define binary-ops
  (set '+ '- '* '/ '% '< '<= '> '>= '&& '\|\| '== '!= '& '\| '^ '~^ '^~ '& '~& '~\| '<< '>> '\,))

(define (binary-op? e)
  (set-member? binary-ops e))

(define-language rtl-adt
  (entry Module)
  (terminals
   (symbol (symbol))
   (size (size))
   (bitwidth (bitwidth))
   (baseident (baseident))
   (literal (literal))
   (unary-op (unop))
   (binary-op (binop)))
  (Register (register)
    (reg symbol)
    (reg symbol size))
  (Constant (constant)
    (const bitwidth baseident literal))
  (Input (input)
    (in symbol)
    (in symbol size))
  (Output (output)
    (out symbol)
    (out symbol size))
  (Port (port)
    input
    output)
  (MemoryRef (memory-ref)
    register
    constant
    input)
  (Memory (memory)
    (mem symbol memory-ref))
  (MemoryDecl (memory-decl)
    (mem symbol size0 size1))
  (Declaration (declaration)
    register
    memory-decl)
  (Target (target)
    register
    memory
    output)
  (Value (value)
    register
    constant
    memory
    input)
  (UnaryOp (unary-op)
    (op unop))
  (BinaryOp (binary-op)
    (op binop))
  (Assign (assign)
    (target value)
    (target unary-op value)
    (target value1 binary-op value2))
  (CaseStatement (case-statement)
    (case value0 (value1 symbol1) ... symbol0))
  (NextState (next-state)
    symbol
    case-statement)
  (State (state)
    (symbol (assign ...) next-state))
  (Operation (operation)
    (symbol (port ...) (state ...)))
  (Module (module)
    (symbol (declaration ...) (operation ...))))

(define-language rtl-fsm
  (extends rtl-adt)
  (AssignState (assign-state)
    (+ (symbol (assign ...))))
  (NextStateState (next-state-state)
    (+ (symbol next-state)))
  (Module (module)
    (- (symbol (declaration ...) (operation ...)))
    (+ (symbol0 (port ...) (symbol1 ...) (declaration ...) (assign-state ...) (next-state-state ...)))))

(define-pass adt-to-fsm : rtl-adt (ast) -> rtl-fsm ()
  (definitions
    (define (extract-operation-names operations)
      (for/list ([operation operations])
        (car operation)))
    (define (extract-ports operations)
      (remove-duplicates
       (flatten
        (map cadr operations))))
    (define (extract-assign-states operations)
      (flatten
       (for/list ([operation operations])
         (for/list ([state (caddr operation)])
           (let ([label (car state)]
                 [assigns (cadr state)])
             (with-output-language (rtl-fsm AssignState)
               `(,label (,assigns ...))))))))
    (define (extract-next-states operations)
      (flatten
       (for/list ([operation operations])
         (for/list ([state (caddr operation)])
           (let ([label (car state)]
                 [next-state (caddr state)])
             (with-output-language (rtl-fsm NextStateState)
               `(,label ,next-state))))))))
  (state-pass : State (s) -> * ()
    [(,symbol (,[assign] ...) ,[next-state])
     (list symbol assign next-state)])
  (operation-pass : Operation (o) -> * ()
    [(,symbol (,[port] ...) (,[state-pass : state] ...))
     (list symbol port state)])
  (module-pass : Module (mo) -> Module ()
    [(,symbol (,[declaration] ...) (,[operation-pass : operation] ...))
     (let ([operation-names (extract-operation-names operation)]
           [ports (extract-ports operation)]
           [assign-states (extract-assign-states operation)]
           [next-states (extract-next-states operation)])
       `(,symbol (,ports ...) (,operation-names ...) (,declaration ...) (,assign-states ...) (,next-states ...)))]))

;; (define-pass output-rtl : rtl-adt (ast) -> * ()
;;   (register-pass : Register (r) -> * ()
;;     [(reg ,symbol) (list 'reg symbol)]
;;     [(reg ,symbol ,size) (list 'reg symbol size)])
;;   (constant-pass : Constant (c) -> * ()
;;     [(const ,bitwidth ,baseident ,literal) (list bitwidth baseident literal)])
;;   (input-pass : Input (i) -> * ()
;;     [(in ,symbol) (list 'in symbol)]
;;     [(in ,symbol ,size) (list 'in symbol size)])
;;   (output-pass : Output (i) -> * ()
;;     [(out ,symbol) (list 'out symbol)]
;;     [(out ,symbol ,size) (list 'out symbol size)])
;;   (port-pass : Port (p) -> * ())
;;   (memory-ref-pass : MemoryRef (mr) -> * ())
;;   (memory-pass : Memory (m) -> * ()
;;     [(mem ,symbol ,[memory-ref-pass : memory-ref]) (list 'mem symbol memory-ref)])
;;   (memory-decl-pass : MemoryDecl (md) -> * ()
;;     [(mem ,symbol ,size0 ,size1) (list 'mem symbol size0 size1)])
;;   (declaration-pass : Declaration (d) -> * ())
;;   (target-pass : Target (t) -> * ())
;;   (value-pass : Value (v) -> * ())
;;   (unary-op-pass : UnaryOp (uo) -> * ()
;;     [(op ,unop) (list 'op unop)])
;;   (binary-op-pass : BinaryOp (bo) -> * ()
;;     [(op ,binop) (list 'op binop)])
;;   (assign-pass : Assign (a) -> * ()
;;     [(,[target-pass : target] ,[value-pass : value])
;;      (list target value)]
;;     [(,[target-pass : target] ,[unary-op-pass : unary-op] ,[value-pass : value])
;;      (list target unary-op value)]
;;     [(,[target-pass : target] ,[value-pass : value1] ,[binary-op-pass : binary-op] ,[value-pass : value2])
;;      (list target value1 binary-op value2)])
;;   (case-statement-pass : CaseStatement (cs) -> * ()
;;     [(case ,[value-pass : value0] (,[value-pass : value1] ,symbol1) ... ,symbol0)
;;      (list 'case value0 (map cons value1 symbol1) symbol0)])
;;   (next-state-pass : NextState (ns) -> * ()
;;     [,symbol symbol])
;;   (state-pass : State (s) -> * ()
;;     [(,symbol (,[assign-pass : assign] ...) ,[next-state-pass : next-state])
;;      (list symbol assign next-state)])
;;   (operation-pass : Operation (o) -> * ()
;;     [(,symbol (,[port-pass : port] ...) (,[state-pass : state] ...))
;;      (list symbol port state)])
;;   (module-pass : Module (mo) -> * ()
;;     [(,symbol (,[declaration-pass : declaration] ...) (,[operation-pass : operation] ...))
;;      (list symbol declaration operation)]))
