#lang nanopass

(require pprint)

(provide
 rtl-adt
 adt-to-fsm
 add-boilerplate
 add-registered-targets
 preprint-to-pprint)

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
    symbol
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
    (case value0 ((value1 symbol1) ...) symbol0))
  (NextState (next-state)
    symbol
    case-statement)
  (State (state)
    (symbol (assign ...) next-state))
  (Operation (operation)
    (symbol (port ...) (state ...)))
  (ModuleName (module-name)
    symbol)
  (Module (module)
    (module-name (declaration ...) (operation ...))))

(define-language rtl-fsm
  (extends rtl-adt)
  (OperationEntry (operation-entry)
    (+ (symbol0 . symbol1)))
  (StateName (state-name)
    (+ symbol))
  (AssignState (assign-state)
    (+ (symbol (assign ...))))
  (NextStateState (next-state-state)
    (+ (symbol next-state)))
  (Module (module)
    (- (module-name
        (declaration ...)
        (operation ...)))
    (+ (module-name
        (port ...)
        (operation-entry ...)
        (state-name ...)
        (declaration ...)
        (assign-state ...)
        (next-state-state ...)))))

(define-pass adt-to-fsm : rtl-adt (ast) -> rtl-fsm ()
  (definitions
    (define (extract-ports operations)
      (remove-duplicates
       (flatten
        (map cadr operations))))
    (define (extract-operation-entries operations)
      (for/list ([operation operations])
        (let ([name (car operation)]
              [entry (car (caaddr operation))])
          (with-output-language (rtl-fsm OperationEntry)
            `(,name . ,entry)))))
    (define (extract-state-names operations)
      (flatten
       (for/list ([operation operations])
         (for/list ([state (caddr operation)])
           (car state)))))
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
    [(,module-name (,[declaration] ...) (,[operation-pass : operation] ...))
     (let ([ports (extract-ports operation)]
           [operation-entries (extract-operation-entries operation)]
           [state-names (extract-state-names operation)]
           [assign-states (extract-assign-states operation)]
           [next-states (extract-next-states operation)])
       `(,module-name
         (,ports ...)
         (,operation-entries ...)
         (,state-names ...)
         (,declaration ...)
         (,assign-states ...)
         (,next-states ...)))]))

(define-pass add-boilerplate : rtl-fsm (ast) -> rtl-fsm ()
  (definitions
    (define (required-size items)
      (let ([upper (- (exact-ceiling (log (length items) 2)) 1)])
        (cons upper 0)))
    (define (clk-port)
      (with-output-language (rtl-fsm Port)
        `(in clk)))
    (define (start-port)
      (with-output-language (rtl-fsm Port)
        `(in start)))
    (define (operation-port operations)
      (let ([size (required-size operations)])
        (with-output-language (rtl-fsm Port)
          `(in operation ,size))))
    (define (busy-port)
      (with-output-language (rtl-fsm Port)
        `(out busy)))
    (define (boilerplate-ports operations)
      (list
       (clk-port)
       (start-port)
       (operation-port operations)
       (busy-port)))
    (define (boilerplate-state-names)
      '(init op_case))
    (define (state-reg states)
      (let ([size (required-size states)])
        (with-output-language (rtl-fsm Declaration)
          `(reg state ,size))))
    (define (next-state-reg states)
      (let ([size (required-size states)])
        (with-output-language (rtl-fsm Declaration)
          `(reg next_state ,size))))
    (define (boilerplate-declarations states)
      (list
       (state-reg states)
       (next-state-reg states)))
    (define (init-assign)
      (with-output-language (rtl-fsm AssignState)
        `(init (((reg busy) (const 1 b 0))))))
    (define (op-case-assign)
      (with-output-language (rtl-fsm AssignState)
        `(op_case (((reg busy) (const 1 b 1))))))
    (define (boilerplate-assign-states)
      (list
       (init-assign)
       (op-case-assign)))
    (define (init-next-state)
      (with-output-language (rtl-fsm NextStateState)
        `(init (case (reg start) (((const 1 b 1) op_case)) init))))
    (define (op-case-next-state operation-entries)
      (let ([case-values (map car operation-entries)]
            [case-labels (map cdr operation-entries)])
        (with-output-language (rtl-fsm NextStateState)
          `(op_case (case (in operation) ((,case-values ,case-labels) ...) init)))))
    (define (boilerplate-next-states operation-entries)
      (list
       (init-next-state)
       (op-case-next-state operation-entries))))
  (operation-entry-pass : OperationEntry (oe) -> * ()
    [(,symbol0 . ,symbol1) (cons symbol0 symbol1)])
  (module-pass : Module (mo) -> Module ()
    [(,module-name
      (,port ...)
      (,operation-entry ...)
      (,state-name ...)
      (,declaration ...)
      (,assign-state ...)
      (,next-state-state ...))
     (let ([operation-entries (map operation-entry-pass operation-entry)])
       (let ([augmented-ports (append (boilerplate-ports operation-entries) port)]
             [augmented-state-names (append (boilerplate-state-names) state-name)]
             [augmented-declarations (append (boilerplate-declarations state-name) declaration)]
             [augmented-assign-states (append (boilerplate-assign-states) assign-state)]
             [augmented-next-states (append (boilerplate-next-states operation-entries) next-state-state)])
         `(,module-name
           (,augmented-ports ...)
           (,operation-entry ...)
           (,augmented-state-names ...)
           (,augmented-declarations ...)
           (,augmented-assign-states ...)
           (,augmented-next-states ...))))]))

(define-language rtl-preprint
  (extends rtl-fsm)
  (RegisteredTarget (registered-target)
   (+ output
      register))
  (Module (module)
    (- (module-name
        (port ...)
        (operation-entry ...)
        (state-name ...)
        (declaration ...)
        (assign-state ...)
        (next-state-state ...)))
    (+ (module-name
        (port ...)
        (operation-entry ...)
        (state-name ...)
        (declaration ...)
        (registered-target ...)
        (assign-state ...)
        (next-state-state ...)))))

(define-pass add-registered-targets : rtl-fsm (ast) -> rtl-preprint ()
  (definitions
    (define (output? e)
      (nanopass-case (rtl-preprint Port) e
        [(out ,symbol) #t]
        [else #f]))
    (define (register? e)
      (nanopass-case (rtl-preprint Declaration) e
        [(reg ,symbol) #t]
        [(reg ,symbol ,size) #t]
        [else #f]))
    (define (extract-outputs ports)
      (filter output? ports))
    (define (extract-registers declarations)
      (filter register? declarations)))
  (module-pass : Module (mo) -> Module ()
    [(,[module-name]
      (,[port] ...)
      (,[operation-entry] ...)
      (,[state-name] ...)
      (,[declaration] ...)
      (,[assign-state] ...)
      (,[next-state-state] ...))
     (let ([outputs (extract-outputs port)]
           [registers (extract-registers declaration)])
       (let ([registered-targets (append outputs registers)])
         `(,module-name
           (,port ...)
           (,operation-entry ...)
           (,state-name ...)
           (,declaration ...)
           (,registered-targets ...)
           (,assign-state ...)
           (,next-state-state ...))))]))

(define-pass preprint-to-pprint : rtl-preprint (ast) -> * ()
  (definitions
    (define op-counter
      (let ([counter -1])
        (lambda ()
          (set! counter (+ 1 counter))
          counter)))
    (define state-counter
      (let ([counter -1])
        (lambda ()
          (set! counter (+ 1 counter))
          counter)))
    (define (pprint-size size)
      (h-append
       lbracket
       (text (number->string (car size)))
       colon
       (text (number->string (cdr size)))
       rbracket))
    (define (pprint-register type name size)
      (h-append
       (hs-append
        (text type)
        (if (empty? size)
            empty
            (pprint-size size))
        (text (symbol->string name)))))
    (define (pprint-localparam symbol counter-proc)
      (h-append
       (hs-append
        (text "localparam")
        (text (symbol->string symbol))
        equals
        (text (number->string (counter-proc))))
       semi)))
  (module-name-pass : ModuleName (mn) -> * ()
    [,symbol (text (symbol->string symbol))])
  (input-pass : Input (i) -> * ()
    [(in ,symbol) (pprint-register "input" symbol null)]
    [(in ,symbol ,size) (pprint-register "input" symbol size)])
  (output-pass : Output (i) -> * ()
    [(out ,symbol) (pprint-register "output reg" symbol null)]
    [(out ,symbol ,size) (pprint-register "output reg" symbol size)])
  (port-pass : Port (p) -> * ())
  (operation-entry-pass : OperationEntry (oe) -> * ()
    [(,symbol0 . ,symbol1) (pprint-localparam symbol0 op-counter)])
  (state-name-pass : StateName (sn) -> * ()
    [,symbol (pprint-localparam symbol state-counter)])
  (register-pass : Register (r) -> * ()
    [(reg ,symbol) (pprint-register "reg" symbol null)]
    [(reg ,symbol ,size) (pprint-register "reg" symbol size)])
  (memory-decl-pass : MemoryDecl (md) -> * ()
    [(mem ,symbol ,size0 ,size1)
     (hs-append
      (pprint-register "reg" symbol size0)
      (pprint-size size1))])
  (declaration-pass : Declaration (d) -> * ()
    [,register (h-append (register-pass register) semi)]
    [,memory-decl (h-append (memory-decl-pass memory-decl) semi)])
  (module-pass : Module (m) -> * ()
    [(,[module-name-pass : doc0]
      (,[port-pass : doc1] ...)
      (,[operation-entry-pass : doc2] ...)
      (,[state-name-pass : doc3] ...)
      (,[declaration-pass : doc4] ...)
      (,registered-target ...)
      (,assign-state ...)
      (,next-state-state ...))
     (v-append
      (nest 2 (v-append
               (hs-append
                (text "module") doc0 (text "("))
               (v-concat
                (apply-infix (text ",") doc1))))
      (nest 2 (v-append
               (text ");")
               (v-concat doc2)
               empty
               (v-concat doc3)
               empty
               (v-concat doc4)))
      (text "endmodule"))]))

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
