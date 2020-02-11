#lang nanopass

(require pprint)

(provide
 rtl0
 adt-to-verilog)

;; globals (ick!)
(define module-signatures (make-hash))
(define module-name-bindings (make-hash))
(define module-port-bindings (make-hash))
(define lowered-entries (make-hash))

;; predicates
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

;; helpers used between passes
(define (required-size items)
  (let ([len (length items)])
    (if (> len 0)
        (let ([required-bits (exact-ceiling (log len 2))])
          (if (> required-bits 1)
              (cons (- required-bits 1) 0)
              null))
        null)))

(define (concat-symbols symbol0 symbol1 sep)
  (string->symbol
   (string-append
    (symbol->string symbol0)
    (symbol->string sep)
    (symbol->string symbol1))))

(define (build-wait-state-name module-name wait-type)
  (concat-symbols module-name (concat-symbols 'wait wait-type '_) '_))

(define (build-continuation-name module-name)
  (concat-symbols module-name 'continue_state '_))

(define-syntax-rule (port-target-to-target lang port-target)
  (with-output-language (lang Target)
    (match port-target
      [(list 'reg name) `(reg ,name)]
      [(list 'reg name size) `(reg ,name)])))

(define-syntax-rule (port-target-to-value lang port-target)
  (with-output-language (lang Value)
    (match port-target
      [(list 'wire name) `(wire ,name)]
      [(list 'wire name size) `(wire ,name)])))

(define-language rtl0
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
  (RegisterDecl (register-decl)
    register
    (register value))
  (MemoryDecl (memory-decl)
    (mem symbol size0 size1))
  (ModuleDecl (module-decl)
    (mod symbol0 symbol1))
  (Declaration (declaration)
    register-decl
    memory-decl
    module-decl)
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
  (ModRef (mod-ref)
    (mod symbol))
  (ModOp (mod-op)
    (op symbol))
  (ModArg (mod-arg)
    symbol
    constant
    register
    memory
    input
    output)
  (Assign (assign)
    (target value)
    (target unary-op value)
    (target value1 binary-op value2))
  (Call (call)
    (invoke mod-ref mod-op mod-arg ...))
  (CaseStatement (case-statement)
    (case value0 ((value1 symbol1) ...) symbol0))
  (Continuation (continuation)
    (symbol0 symbol1 symbol2))
  (NextState (next-state)
    symbol
    continuation
    case-statement)
  (Action (action)
    assign
    call)
  (State (state)
    (symbol (action ...) next-state))
  (Operation (operation)
    (symbol (port ...) (state ...)))
  (ModuleName (module-name)
    symbol)
  (Module (module)
    (module-name (declaration ...) (operation ...))))

(define-language rtl1
  (extends rtl0)
  (Module (module)
    (- (module-name
        (declaration ...)
        (operation ...)))
    (+ (module-name
        (port ...)
        (declaration ...)
        (operation ...)))))

(define-pass add-ports : rtl0 (ast) -> rtl1 ()
  (definitions
    (define (extract-ports operations)
      (remove-duplicates
       (append-map extract-port operations)))
    (define (extract-port operation)
      (nanopass-case (rtl1 Operation) operation
        [(,symbol (,port ...) (,state ...)) port])))
  (module-pass : Module (mo) -> Module ()
    [(,module-name
      (,[declaration] ...)
      (,[operation] ...))
     (let ([ports (extract-ports operation)])
       `(,module-name
         (,ports ...)
         (,declaration ...)
         (,operation ...)))]))

(define-pass add-boilerplate-ports : rtl1 (ast) -> rtl1 ()
  (definitions
    (define (clk-port)
      (with-output-language (rtl1 Port)
        `(in clk)))
    (define (start-port)
      (with-output-language (rtl1 Port)
        `(in start)))
    (define (operation-port operations)
      (let ([size (required-size operations)])
        (with-output-language (rtl1 Port)
          (if (empty? size)
              `(in operation)
              `(in operation ,size)))))
    (define (busy-port)
      (with-output-language (rtl1 Port)
        `(out busy)))
    (define (boilerplate-ports operations)
      (list
       (clk-port)
       (start-port)
       (operation-port operations)
       (busy-port))))
  (module-pass : Module (mo) -> Module ()
    [(,module-name
      (,port ...)
      (,declaration ...)
      (,operation ...))
     (let ([augmented-ports (append (boilerplate-ports operation) port)])
       `(,module-name
         (,augmented-ports ...)
         (,declaration ...)
         (,operation ...)))]))

(define-pass store-module-signature! : rtl1 (ast) -> rtl1 ()
  (definitions
    (define (extract-ports ports)
      (for/list ([port ports])
        (nanopass-case (rtl1 Port) port
          [(in ,symbol) `(in ,symbol)]
          [(in ,symbol ,size) `(in ,symbol ,size)]
          [(out ,symbol) `(out ,symbol)]
          [(out ,symbol ,size) `(out ,symbol ,size)])))
    (define (extract-operations operations)
      (for/hash ([operation operations])
        (nanopass-case (rtl1 Operation) operation
          [(,symbol (,port ...) (,state ...))
           (values symbol (extract-ports port))]))))
  (module-pass : Module (mo) -> Module ()
    [(,module-name
      (,port ...)
      (,declaration ...)
      (,operation ...))
     (let ([ports (extract-ports port)]
           [operations (extract-operations operation)])
       (let ([module-entry (hash 'ports ports 'operations operations)])
         (hash-set! module-signatures module-name module-entry)
         `(,module-name
           (,port ...)
           (,declaration ...)
           (,operation ...))))]))

(define-language rtl2
  (extends rtl1)
  (WireRef (wire-ref)
    ( + (wire symbol)
        (wire symbol size)))
  (Value (value)
    ( + wire-ref))
  (PortTarget (port-target)
    ( + input
        register
        wire-ref))
  (PortBinding (port-binding)
    ( + (port port-target)))
  (ModuleDecl (module-decl)
    ( - (mod symbol0 symbol1))
    ( + (mod symbol0 symbol1 (port-binding ...))))
  (Declaration (declaration)
    ( + wire-ref)))

(define-pass add-module-port-bindings : rtl1 (ast) -> rtl2 ()
  (definitions
    (define (lookup-module-signature module-name)
      (hash-ref module-signatures module-name
        (lambda ()
          (error (format "module named ~v not found" module-name)))))
    (define (build-port-term port)
      (with-output-language (rtl2 Port)
        (match port
          [(list 'in name) `(in ,name)]
          [(list 'in name size) `(in ,name ,size)]
          [(list 'out name) `(out ,name)]
          [(list 'out name size) `(out ,name ,size)])))
    (define (build-port-target-name instance-name port-name)
      (if (eq? port-name 'clk)
          'clk
          (concat-symbols instance-name port-name '_)))
    (define (build-port-target-size port)
      (if (empty? (cddr port))
          null
          (caddr port)))
    (define (build-port-target instance-name port)
      (let ([port-type (car port)]
            [port-name (cadr port)])
        (let ([port-target-name (build-port-target-name instance-name port-name)]
              [port-target-size (build-port-target-size port)])
          (with-output-language (rtl2 PortTarget)
            (cond [(eq? port-type 'in)
                   (if (eq? port-name 'clk)
                       `(in clk)
                       (if (empty? port-target-size)
                           `(reg ,port-target-name)
                           `(reg ,port-target-name ,port-target-size)))]
                  [(eq? port-type 'out)
                   (if (empty? port-target-size)
                       `(wire ,port-target-name)
                       `(wire ,port-target-name ,port-target-size))])))))
    (define (build-port-bindings instance-name ports)
      (with-output-language (rtl2 PortBinding)
        (for/list ([port ports])
          (let ([port-term (build-port-term port)]
                [port-target (build-port-target instance-name port)])
            `(,port-term ,port-target))))))
  (module-decl-pass : ModuleDecl (md) -> ModuleDecl ()
    [(mod ,symbol0 ,symbol1)
     (let ([module-signature (lookup-module-signature symbol0)])
       (let ([module-ports (hash-ref module-signature 'ports)])
         (let ([port-bindings (build-port-bindings symbol1 module-ports)])
           `(mod ,symbol0 ,symbol1 (,port-bindings ...)))))]))

(define-pass store-module-bindings! : rtl2 (ast) -> rtl2 ()
  (definitions
    (define (extract-name port)
      (nanopass-case (rtl2 Port) port
        [(in ,symbol) symbol]
        [(in ,symbol ,size) symbol]
        [(out ,symbol) symbol]
        [(out ,symbol ,size) symbol]))
    (define (extract-port-target port-target)
      (nanopass-case (rtl2 PortTarget) port-target
        [(in ,symbol) `(in ,symbol)]
        [(in ,symbol ,size) `(in ,symbol ,size)]
        [(reg ,symbol) `(reg ,symbol)]
        [(reg ,symbol ,size) `(reg ,symbol ,size)]
        [(wire ,symbol) `(wire ,symbol)]
        [(wire ,symbol ,size) `(wire ,symbol ,size)]))
    (define (build-port-binding-hash port-bindings)
      (for/hash ([port-binding port-bindings])
        (nanopass-case (rtl2 PortBinding) port-binding
          [(,port ,port-target)
           (values (extract-name port) (extract-port-target port-target))]))))
  (module-decl-pass : ModuleDecl (md) -> ModuleDecl ()
    [(mod ,symbol0 ,symbol1 (,port-binding ...))
     (let ([port-binding-hash (build-port-binding-hash port-binding)])
       (hash-set! module-name-bindings symbol1 symbol0)
       (hash-set! module-port-bindings symbol1 port-binding-hash)
       `(mod ,symbol0 ,symbol1 (,port-binding ...)))]))

(define-pass add-port-binding-declarations : rtl2 (ast) -> rtl2 ()
  (definitions
    (define (not-clk? port-target)
      (nanopass-case (rtl2 PortTarget) port-target
        [(in ,symbol) (not (eq? symbol 'clk))]
        [(in ,symbol ,size) (not (eq? symbol 'clk))]
        [else #t]))
    (define (extract-port-targets port-bindings)
      (filter
       not-clk?
       (for/list ([port-binding port-bindings])
         (nanopass-case (rtl2 PortBinding) port-binding
           [(,port ,port-target) port-target]))))
    (define (extract-port-bindings declaration)
      (nanopass-case (rtl2 Declaration) declaration
        [(mod ,symbol0 ,symbol1 (,port-binding ...)) (extract-port-targets port-binding)]
        [else null]))
    (define (build-port-binding-declarations declarations)
      (append-map
       (lambda (declaration)
         (list* declaration (extract-port-bindings declaration)))
       declarations)))
  (module-pass : Module (m) -> Module ()
    [(,module-name
      (,port ...)
      (,declaration ...)
      (,operation ...))
     (let ([augmented-declarations (build-port-binding-declarations declaration)])
       `(,module-name
         (,port ...)
         (,augmented-declarations ...)
         (,operation ...)))]))

(define-language rtl3
  (extends rtl2)
  (Action (action)
    ( - call)))

(define-pass lower-module-calls : rtl2 (ast) -> rtl3 ()
  (definitions
    (define not-null? (compose1 not null?))
    (define (call-action? action)
      (nanopass-case (rtl2 Action) action
        [(invoke ,mod-ref ,mod-op ,mod-arg ...) #t]
        [else #f]))
    (define (symbol-next-state? next-state)
      (nanopass-case (rtl2 NextState) next-state
        [,symbol #t]
        [else #f]))
    (define (module-operation? state)
      (nanopass-case (rtl2 State) state
        [(,symbol (,action ...) ,next-state)
         (let ([call-actions (filter call-action? action)]
               [is-next-state-symbol (symbol-next-state? next-state)])
           (if (> (length call-actions) 1)
               (error "multiple call operations in one state are currently not supported")
               (if (> (length call-actions) 0)
                   (if (not is-next-state-symbol)
                       (error "call operation currently requires a symbol for next state")
                       #t)
                   #f)))]))
    (define (build-state-name state-name suffix)
      (concat-symbols state-name suffix '_))
    (define (extract-module-name mod-ref)
      (nanopass-case (rtl2 ModRef) mod-ref
        [(mod ,symbol) symbol]))
    (define (extract-operation-name mod-op)
      (nanopass-case (rtl2 ModOp) mod-op
        [(op ,symbol) symbol]))
    (define (build-boilerplate-start-assigns module-name operation-name)
      (let ([port-bindings (hash-ref module-port-bindings module-name)])
        (let ([start-reg (hash-ref port-bindings 'start)]
              [operation-reg (hash-ref port-bindings 'operation)])
          (let ([start-target (port-target-to-target rtl3 start-reg)]
                [start-value (with-output-language (rtl3 Value) `(const 1 b 1))]
                [operation-target (port-target-to-target rtl3 operation-reg)]
                [operation-value (concat-symbols module-name operation-name '\.)])
            (with-output-language (rtl3 Assign)
              (list
               `(,start-target ,start-value)
               `(,operation-target ,operation-value)))))))
    (define (process-build-assigns boilerplate-start-assigns start-assigns done-assigns)
      (values
       (append
        boilerplate-start-assigns
        (filter not-null? start-assigns))
       (filter not-null? done-assigns)))
    (define (build-assigns action)
      (nanopass-case (rtl2 Action) action
        [(invoke ,mod-ref ,mod-op ,mod-arg ...)
         (let ([module-name (extract-module-name mod-ref)]
               [operation-name (extract-operation-name mod-op)])
           (let ([bound-module-name (hash-ref module-name-bindings module-name)]
                 [port-bindings (hash-ref module-port-bindings module-name)])
             (let ([module-signature (hash-ref module-signatures bound-module-name)]
                   [boilerplate-start-assigns
                    (build-boilerplate-start-assigns module-name operation-name)])
               (let ([ports (hash-ref (hash-ref module-signature 'operations) operation-name)])
                 (if (not (eq? (length mod-arg) (length ports)))
                     (error "module operation arguments do not match operation's ports")
                     (for/lists (start-assigns done-assigns
                                  #:result (process-build-assigns
                                            boilerplate-start-assigns
                                            start-assigns
                                            done-assigns))
                                ([i (in-range (length ports))])
                       (let ([port (list-ref ports i)]
                             [arg (list-ref mod-arg i)])
                         (let ([port-target (hash-ref port-bindings (cadr port))])
                           (with-output-language (rtl3 Assign)
                             (cond [(eq? (car port-target) 'reg)
                                    (let ([target (port-target-to-target rtl3 port-target)]
                                          [value (mod-arg-to-value arg)])
                                      (values `(,target ,value) null))]
                                   [(eq? (car port-target) 'wire)
                                    (let ([target (mod-arg-to-target arg)]
                                          [value (port-target-to-value rtl3 port-target)])
                                      (values null `(,target ,value)))]))))))))))]))
    (define (build-start-next-state action done-state)
      (nanopass-case (rtl2 Action) action
        [(invoke ,mod-ref ,mod-op ,mod-arg ...)
         (let ([module-name (extract-module-name mod-ref)])
           (let ([next-state (build-wait-state-name module-name 'busy)]
                 [continue-name (build-continuation-name module-name)])
             (with-output-language (rtl3 NextState)
               `(,next-state ,continue-name ,done-state))))]))
    (define (build-states state)
      (nanopass-case (rtl2 State) state
        [(,symbol (,action ...) ,next-state)
         (let ([single-action (car action)]) ; only dealing with one for now
           (let ([start-symbol (build-state-name symbol 'start)]
                 [done-symbol (build-state-name symbol 'done)])
             (hash-set! lowered-entries symbol start-symbol)
             (let ([start-next-state (build-start-next-state single-action done-symbol)])
               (let-values ([(start-assigns done-assigns) (build-assigns single-action)])
                 (with-output-language (rtl3 State)
                   (list
                    `(,start-symbol (,start-assigns ...) ,start-next-state)
                    `(,done-symbol (,done-assigns ...) ,next-state)))))))]))
    (define (build-lowered-states states)
      (append-map
       (lambda (state)
         (if (module-operation? state)
             (build-states state)
             (list (state-pass state))))
       states)))
  (mod-arg-to-target : ModArg (ma) -> Target ())
  (mod-arg-to-value : ModArg (ma) -> Value ())
  (state-pass : State (s) -> State ())
  (operation-pass : Operation (o) -> Operation ()
    [(,symbol (,[port] ...) (,state ...))
     (let ([augmented-states (build-lowered-states state)])
       `(,symbol (,port ...) (,augmented-states ...)))]))

(define-pass adjust-lowered-entries : rtl3 (ast) -> rtl3 ()
  (definitions
    (define (adjust-symbol original-next-state)
      (hash-ref lowered-entries original-next-state original-next-state)))
  (next-state-pass : NextState (n) -> NextState ()
    [,symbol (adjust-symbol symbol)]
    [(case ,value0 ((,value1 ,symbol1) ...) ,symbol0)
     (let ([adjusted-next-states (map adjust-symbol symbol1)]
           [adjusted-else-state (adjust-symbol symbol0)])
       `(case ,value0 ((,value1 ,adjusted-next-states) ...) ,adjusted-else-state))]))

(define-language rtl4
  (extends rtl3)
  (DefaultAssign (default-assign)
   (+ (symbol0 . symbol1)))
  (Module (module)
    (- (module-name
        (port ...)
        (declaration ...)
        (operation ...)))
    (+ (module-name
        (port ...)
        (declaration ...)
        (default-assign ...)
        (operation ...)))))

(define-pass add-default-assigns : rtl3 (ast) -> rtl4 ()
  (definitions
    (define defaults
      (with-output-language (rtl4 DefaultAssign)
        (list
         `(state . next_state))))
    (define system-registers
      (set 'state 'next_state))
    (define (output? e)
      (nanopass-case (rtl4 Port) e
        [(out ,symbol) #t]
        [(out ,symbol ,size) #t]
        [else #f]))
    (define (register? e)
      (nanopass-case (rtl4 Declaration) e
        [(reg ,symbol) (not (set-member? system-registers symbol))]
        [(reg ,symbol ,size) (not (set-member? system-registers symbol))]
        [((reg ,symbol) ,value) (not (set-member? system-registers symbol))]
        [((reg ,symbol ,size) ,value) (not (set-member? system-registers symbol))]
        [else #f]))
    (define (module? e)
      (nanopass-case (rtl4 Declaration) e
        [,module-decl #t]
        [else #f]))
    (define (extract-output e)
      (nanopass-case (rtl4 Port) e
        [(out ,symbol)
         (with-output-language (rtl4 DefaultAssign)
           `(,symbol . ,symbol))]
        [(out ,symbol ,size)
         (with-output-language (rtl4 DefaultAssign)
           `(,symbol . ,symbol))]))
    (define (extract-register e)
      (nanopass-case (rtl4 Declaration) e
        [(reg ,symbol)
         (with-output-language (rtl4 DefaultAssign)
           `(,symbol . ,symbol))]
        [(reg ,symbol ,size)
         (with-output-language (rtl4 DefaultAssign)
           `(,symbol . ,symbol))]
        [((reg ,symbol) ,value)
         (with-output-language (rtl4 DefaultAssign)
           `(,symbol . ,symbol))]
        [((reg ,symbol ,size) ,value)
         (with-output-language (rtl4 DefaultAssign)
           `(,symbol . ,symbol))]))
    (define (extract-continuation e)
      (nanopass-case (rtl4 Declaration) e
        [(mod ,symbol0 ,symbol1 (,port-binding ...))
         (let ([continuation-name (build-continuation-name symbol1)])
           (with-output-language (rtl4 DefaultAssign)
             `(,continuation-name . ,continuation-name)))])))
  (module-pass : Module (mo) -> Module ()
    [(,[module-name]
      (,[port] ...)
      (,[declaration] ...)
      (,[operation] ...))
     (let ([outputs (map extract-output (filter output? port))]
           [registers (map extract-register (filter register? declaration))]
           [module-continuations (map extract-continuation (filter module? declaration))])
       (let ([default-assigns (append defaults outputs registers module-continuations)])
         `(,module-name
           (,port ...)
           (,declaration ...)
           (,default-assigns ...)
           (,operation ...))))]))

(define-language rtl5
  (extends rtl4)
  (OperationEntry (operation-entry)
    (+ (symbol0 . symbol1)))
  (Module (module)
    (- (module-name
        (port ...)
        (declaration ...)
        (default-assign ...)
        (operation ...)))
    (+ (module-name
        (port ...)
        (operation-entry ...)
        (declaration ...)
        (default-assign ...)
        (operation ...)))))

(define-pass add-operation-entries : rtl4 (ast) -> rtl5 ()
  (definitions
    (define (extract-operation-entries operations)
      (for/list ([operation operations])
        (nanopass-case (rtl5 Operation) operation
          [(,symbol (,port ...) (,state ...))
           (let ([operation-name symbol]
                 [entry (car state)])
             (nanopass-case (rtl5 State) entry
               [(,symbol (,assign ...) ,next-state)
                (let ([state-name symbol])
                  (with-output-language (rtl5 OperationEntry)
                    `(,operation-name . ,state-name)))]))]))))
  (module-pass : Module (mo) -> Module ()
    [(,[module-name]
      (,[port] ...)
      (,[declaration] ...)
      (,[default-assign] ...)
      (,[operation] ...))
     (let ([operation-entries (extract-operation-entries operation)])
       `(,module-name
         (,port ...)
         (,operation-entries ...)
         (,declaration ...)
         (,default-assign ...)
         (,operation ...)))]))

(define-language rtl6
  (extends rtl5)
  (StateName (state-name)
    (+ symbol))
  (Module (module)
    (- (module-name
        (port ...)
        (operation-entry ...)
        (declaration ...)
        (default-assign ...)
        (operation ...)))
    (+ (module-name
        (port ...)
        (operation-entry ...)
        (state-name ...)
        (declaration ...)
        (default-assign ...)
        (operation ...)))))

(define-pass add-state-names : rtl5 (ast) -> rtl6 ()
  (definitions
    (define (extract-state-names operations)
      (append-map
       (lambda (operation)
        (nanopass-case (rtl6 Operation) operation
          [(,symbol (,port ...) (,state ...))
           (for/list ([state state])
             (nanopass-case (rtl6 State) state
               [(,symbol (,action ...) ,next-state) symbol]))]))
       operations)))
  (module-pass : Module (mo) -> Module ()
    [(,module-name
      (,[port] ...)
      (,[operation-entry] ...)
      (,[declaration] ...)
      (,[default-assign] ...)
      (,[operation] ...))
     (let ([state-names (extract-state-names operation)])
       `(,module-name
         (,port ...)
         (,operation-entry ...)
         (,state-names ...)
         (,declaration ...)
         (,default-assign ...)
         (,operation ...)))]))

(define-language rtl7
  (extends rtl6)
  (AssignState (assign-state)
    (+ (symbol (assign ...))))
  (NextStateState (next-state-state)
    (+ (symbol next-state)))
  (Module (module)
    (- (module-name
        (port ...)
        (operation-entry ...)
        (state-name ...)
        (declaration ...)
        (default-assign ...)
        (operation ...)))
    (+ (module-name
        (port ...)
        (operation-entry ...)
        (state-name ...)
        (declaration ...)
        (default-assign ...)
        (assign-state ...)
        (next-state-state ...)))))

(define-pass split-states : rtl6 (ast) -> rtl7 ()
  (definitions
    (define (extract-state-pairs operations)
      (for/lists (assigns nexts #:result (values (apply append assigns) (apply append nexts)))
                 ([operation operations])
        (nanopass-case (rtl7 Operation) operation
          [(,symbol (,port ...) (,state ...))
           (for/lists (_assigns _nexts)
                      ([state state])
             (nanopass-case (rtl7 State) state
               [(,symbol (,assign ...) ,next-state)
                (values
                 (with-output-language (rtl7 AssignState)
                   `(,symbol (,assign ...)))
                 (with-output-language (rtl7 NextStateState)
                   `(,symbol ,next-state)))]))]))))
  (module-pass : Module (mo) -> Module ()
    [(,module-name
      (,[port] ...)
      (,[operation-entry] ...)
      (,[state-name] ...)
      (,[declaration] ...)
      (,[default-assign] ...)
      (,[operation] ...))
     (let-values ([(assign-states next-state-states) (extract-state-pairs operation)])
       `(,module-name
         (,port ...)
         (,operation-entry ...)
         (,state-name ...)
         (,declaration ...)
         (,default-assign ...)
         (,assign-states ...)
         (,next-state-states ...)))]))

(define-pass add-boilerplate-states : rtl7 (ast) -> rtl7 ()
  (definitions
    (define (extract-module-declarations declarations)
      (filter-map
       (lambda (declaration)
         (nanopass-case (rtl7 Declaration) declaration
           [,module-decl
            (nanopass-case (rtl7 ModuleDecl) module-decl
              [(mod ,symbol0 ,symbol1 (,port-binding ...)) symbol1])]
           [else #f]))
       declarations))
    (define (build-module-wait-states module-name)
      (list
       (build-wait-state-name module-name 'busy)
       (build-wait-state-name module-name 'done)))
    (define (boilerplate-state-names declared-modules)
      (let ([module-wait-states (append-map build-module-wait-states declared-modules)])
        (append
         '(init op_case)
         module-wait-states)))
    (define (build-module-continuations size declared-modules)
      (map
       (lambda (module-name)
         (let ([register-name (build-continuation-name module-name)])
           (with-output-language (rtl7 Declaration)
             (if (empty? size)
                 `(reg ,register-name)
                 `(reg ,register-name ,size)))))
       declared-modules))
    (define (state-reg size)
      (with-output-language (rtl7 Declaration)
        (if (empty? size)
            `(reg state)
            `(reg state ,size))))
    (define (next-state-reg size)
      (with-output-language (rtl7 Declaration)
        (if (empty? size)
            `(reg next_state)
            `(reg next_state ,size))))
    (define (boilerplate-declarations states declared-modules)
      (let ([size (required-size states)])
        (let ([module-continuations (build-module-continuations size declared-modules)])
          (append
           (list
            (state-reg size)
            (next-state-reg size))
           module-continuations))))
    (define (build-wait-assign-states module-name)
      (let ([busy-name (build-wait-state-name module-name 'busy)]
            [done-name (build-wait-state-name module-name 'done)]
            [start-reg (hash-ref (hash-ref module-port-bindings module-name) 'start)])
        (let ([start-target (port-target-to-target rtl7 start-reg)])
          (with-output-language (rtl7 AssignState)
            (list
             `(,busy-name ((,start-target (const 1 b 0))))
             `(,done-name ()))))))
    (define (init-assign)
      (with-output-language (rtl7 AssignState)
        `(init (((reg busy) (const 1 b 0))))))
    (define (op-case-assign)
      (with-output-language (rtl7 AssignState)
        `(op_case (((reg busy) (const 1 b 1))))))
    (define (boilerplate-assign-states declared-modules)
      (let ([module-assign-states (append-map build-wait-assign-states declared-modules)])
        (append
         (list
          (init-assign)
          (op-case-assign))
         module-assign-states)))
    (define (extract-reg-name reg)
      (match reg
        [(list 'reg name) name]
        [(list 'reg name size) name]))
    (define (build-wait-next-states module-name)
      (let ([busy-name (build-wait-state-name module-name 'busy)]
            [done-name (build-wait-state-name module-name 'done)]
            [continue-name (build-continuation-name module-name)]
            [busy-wire (hash-ref (hash-ref module-port-bindings module-name) 'busy)])
        (let ([busy-value (port-target-to-value rtl7 busy-wire)])
          (with-output-language (rtl7 NextStateState)
            (list
             `(,busy-name (case ,busy-value (((const 1 b 0) ,busy-name)) ,done-name))
             `(,done-name (case ,busy-value (((const 1 b 1) ,done-name)) ,continue-name)))))))
    (define (init-next-state)
      (with-output-language (rtl7 NextStateState)
        `(init (case (reg start) (((const 1 b 1) op_case)) init))))
    (define (extract-operation-entries operation-entries)
      (for/lists (_operations _states)
                 ([operation-entry operation-entries])
        (nanopass-case (rtl7 OperationEntry) operation-entry
          [(,symbol0 . ,symbol1) (values symbol0 symbol1)])))
    (define (op-case-next-state operation-entries)
      (let-values ([(case-values case-labels) (extract-operation-entries operation-entries)])
        (with-output-language (rtl7 NextStateState)
          `(op_case (case (in operation) ((,case-values ,case-labels) ...) init)))))
    (define (boilerplate-next-states operation-entries declared-modules)
      (let ([module-next-states (append-map build-wait-next-states declared-modules)])
        (append
         (list
          (init-next-state)
          (op-case-next-state operation-entries))
         module-next-states))))
  (module-pass : Module (mo) -> Module ()
    [(,module-name
      (,port ...)
      (,operation-entry ...)
      (,state-name ...)
      (,declaration ...)
      (,default-assign ...)
      (,assign-state ...)
      (,next-state-state ...))
     (let ([declared-modules (extract-module-declarations declaration)])
       (let ([augmented-state-names
              (append (boilerplate-state-names declared-modules) state-name)])
         (let ([augmented-declarations
                (append (boilerplate-declarations augmented-state-names declared-modules) declaration)]
               [augmented-assign-states
                (append (boilerplate-assign-states declared-modules) assign-state)]
               [augmented-next-states
                (append (boilerplate-next-states operation-entry declared-modules) next-state-state)])
           `(,module-name
             (,port ...)
             (,operation-entry ...)
             (,augmented-state-names ...)
             (,augmented-declarations ...)
             (,default-assign ...)
             (,augmented-assign-states ...)
             (,augmented-next-states ...)))))]))

(define-pass rtl-to-pprint : rtl7 (ast) -> * ()
  (definitions
    (define module (text "module"))
    (define endmodule (text "endmodule"))
    (define begin (text "begin"))
    (define end (text "end"))
    (define case (text "case"))
    (define endcase (text "endcase"))
    (define default (text "default"))
    (define localparam (text "localparam"))
    (define state (text "state"))
    (define next_state (text "next_state"))
    (define always (text "always"))
    (define at (text "@"))
    (define or (text "or"))
    (define posedge (text "posedge"))
    (define clk (text "clk"))
    (define start (text "start"))
    (define assign (text "<="))
    (define input (text "input"))
    (define output-reg (text "output reg"))
    (define reg (text "reg"))
    (define wire (text "wire"))

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

    (define (symtext symbol)
      (text (symbol->string symbol)))
    (define (numtext number)
      (text (number->string number)))
    (define (with-semi doc)
      (h-append doc semi))

    (define (pprint-size size)
      (h-append
       lbracket
       (numtext (car size))
       colon
       (numtext (cdr size))
       rbracket))
    (define (pprint-register type name size)
      (h-append
       (hs-append
        type
        (if (empty? size)
            empty
            (pprint-size size))
        (symtext name))))
    (define (pprint-localparam symbol counter-proc)
      (with-semi
       (hs-append
        localparam
        (symtext symbol)
        equals
        (numtext (counter-proc)))))
    (define (pprint-binop left op right)
      (cond
        [(equal? (pretty-format op) ",") (hs-append lbrace left op right rbrace)]
        [else (hs-append left op right)]))
    (define (pprint-next-state-case value symbol)
      (v-append
       (nest 2 (v-append
                (hs-append
                 (h-append
                  value
                  colon)
                 begin)
                (with-semi
                 (hs-append
                  next_state
                  equals
                  (symtext symbol)))))
       end)))

  (module-name-pass : ModuleName (mn) -> * ()
    [,symbol (symtext symbol)])
  (input-pass : Input (i) -> * ()
    [(in ,symbol) (pprint-register input symbol null)]
    [(in ,symbol ,size) (pprint-register input symbol size)])
  (input-value-pass : Input (i) -> * ()
    [(in ,symbol) (symtext symbol)]
    [(in ,symbol ,size)
     (h-append (symtext symbol) (pprint-size size))])
  (input-name-pass : Input (i) -> * ()
    [(in ,symbol) (symtext symbol)]
    [(in ,symbol ,size) (symtext symbol)])
  (output-pass : Output (i) -> * ()
    [(out ,symbol) (pprint-register output-reg symbol null)]
    [(out ,symbol ,size) (pprint-register output-reg symbol size)])
  (output-value-pass : Output (o) -> * ()
    [(out ,symbol) (symtext symbol)]
    [(out ,symbol ,size)
     (h-append (symtext symbol) (pprint-size size))])
  (output-name-pass : Output (i) -> * ()
    [(out ,symbol) (symtext symbol)]
    [(out ,symbol ,size) (symtext symbol)])
  (port-pass : Port (p) -> * ()
    [,input (input-pass input)]
    [,output (output-pass output)])
  (port-name-pass : Port (p) -> * ()
    [,input (input-name-pass input)]
    [,output (output-name-pass output)])
  (operation-entry-pass : OperationEntry (oe) -> * ()
    [(,symbol0 . ,symbol1) (pprint-localparam symbol0 op-counter)])
  (state-name-pass : StateName (sn) -> * ()
    [,symbol (pprint-localparam symbol state-counter)])
  (register-pass : Register (r) -> * ()
    [(reg ,symbol) (pprint-register reg symbol null)]
    [(reg ,symbol ,size) (pprint-register reg symbol size)])
  (register-value-pass : Register (r) -> * ()
    [(reg ,symbol) (symtext symbol)]
    [(reg ,symbol ,size)
     (h-append (symtext symbol) (pprint-size size))])
  (register-name-pass : Register (r) -> * ()
    [(reg ,symbol) (symtext symbol)]
    [(reg ,symbol ,size) (symtext symbol)])
  (wire-ref-pass : WireRef (w) -> * ()
    [(wire ,symbol) (pprint-register wire symbol null)]
    [(wire ,symbol ,size) (pprint-register wire symbol size)])
  (wire-ref-value-pass : WireRef (w) -> * ()
    [(wire ,symbol) (symtext symbol)]
    [(wire ,symbol ,size)
     (h-append (symtext symbol) (pprint-size size))])
  (wire-ref-name-pass : WireRef (w) -> * ()
    [(wire ,symbol) (symtext symbol)]
    [(wire ,symbol ,size) (symtext symbol)])
  (constant-pass : Constant (c) -> * ()
    [(const ,bitwidth ,baseident ,literal)
     (h-append (numtext bitwidth) squote (symtext baseident)
               (cond [(number? literal) (numtext literal)]
                     [(symbol? literal) (symtext literal)]))])
  (memory-ref-pass : MemoryRef (mr) -> * ()
    [,register (register-value-pass register)]
    [,constant (constant-pass constant)]
    [,input (input-value-pass input)])
  (memory-pass : Memory (m) -> * ()
    [(mem ,symbol ,[memory-ref-pass : doc])
     (h-append (symtext symbol) lbracket doc rbracket)])
  (value-pass : Value (v) -> * ()
    [,symbol (symtext symbol)]
    [,register (register-value-pass register)]
    [,constant (constant-pass constant)]
    [,memory (memory-pass memory)]
    [,input (input-value-pass input)]
    [,wire-ref (wire-ref-value-pass wire-ref)])
  (register-decl-pass : RegisterDecl (rd) -> * ()
    [,register (register-pass register)]
    [(,[register-pass : register] ,[value-pass : value])
     (hs-append register equals value)])
  (memory-decl-pass : MemoryDecl (md) -> * ()
    [(mem ,symbol ,size0 ,size1)
     (hs-append (pprint-register reg symbol size0) (pprint-size size1))])
  (port-target-pass : PortTarget (pt) -> * ()
    [,input (input-name-pass input)]
    [,register (register-name-pass register)]
    [,wire-ref (wire-ref-name-pass wire-ref)])
  (port-binding-pass : PortBinding (pb) -> * ()
    [(,[port-name-pass : doc0] ,[port-target-pass : doc1])
     (h-append dot doc0 lparen doc1 rparen)])
  (module-decl-pass : ModuleDecl (md) -> * ()
    [(mod ,symbol0 ,symbol1 (,[port-binding-pass : doc] ...))
     (v-append
      line
      (nest 2 (v-append
               (hs-append (symtext symbol0) (h-append (symtext symbol1) lparen))
               (v-concat (apply-infix comma doc))))
      rparen)])
  (declaration-pass : Declaration (d) -> * ()
    [,register-decl (with-semi (register-decl-pass register-decl))]
    [,wire-ref (with-semi (wire-ref-pass wire-ref))]
    [,memory-decl (with-semi (memory-decl-pass memory-decl))]
    [,module-decl (with-semi (module-decl-pass module-decl))])
  (default-assign-pass : DefaultAssign (da) -> * ()
    [(,symbol0 . ,symbol1)
     (with-semi (hs-append (symtext symbol0) assign (symtext symbol1)))])
  (target-pass : Target (t) -> * ()
    [,register (register-value-pass register)]
    [,memory (memory-pass memory)]
    [,output (output-value-pass output)])
  (unary-op-pass : UnaryOp (uo) -> * ()
    [(op ,unop) (symtext unop)])
  (binary-op-pass : BinaryOp (bo) -> * ()
    [(op ,binop) (symtext binop)])
  (assign-pass : Assign (a) -> * ()
    [(,[target-pass : doc0] ,[value-pass : doc1])
     (with-semi (hs-append doc0 assign doc1))]
    [(,[target-pass : doc0] ,[unary-op-pass : doc1] ,[value-pass : doc2])
     (with-semi (hs-append doc0 assign doc1 doc2))]
    [(,[target-pass : doc0] ,[value-pass : doc1] ,[binary-op-pass : doc2] ,[value-pass : doc3])
     (with-semi (hs-append doc0 assign (pprint-binop doc1 doc2 doc3)))])
  (assign-state-pass : AssignState (as) -> * ()
    [(,symbol (,[assign-pass : doc] ...))
     (v-append
      (nest 2 (v-append
               (hs-append (h-append (symtext symbol) colon) begin)
               (v-concat doc)))
      end)])
  (case-statement-pass : CaseStatement (cs) -> * ()
    [(case ,[value-pass : doc0] ((,[value-pass : doc1] ,symbol1) ...) ,symbol0)
     (v-append
      (nest 2 (v-append
               (h-append
                case
                lparen
                doc0
                rparen)
               (v-concat (map pprint-next-state-case doc1 symbol1))
               (v-append
                (nest 2 (v-append
                         (hs-append (h-append default colon) begin)
                         (with-semi (hs-append next_state equals (symtext symbol0)))))
                end)))
      endcase)])
  (continuation-pass : Continuation (c) -> * ()
    [(,symbol0 ,symbol1 ,symbol2)
     (v-append
      (with-semi (hs-append next_state equals (symtext symbol0)))
      (with-semi (hs-append (symtext symbol1) equals (symtext symbol2))))])
  (next-state-pass : NextState (ns) -> * ()
    [,symbol
     (with-semi (hs-append next_state equals (symtext symbol)))]
    [,continuation (continuation-pass continuation)]
    [,case-statement (case-statement-pass case-statement)])
  (next-state-state-pass : NextStateState (nss) -> * ()
    [(,symbol ,[next-state-pass : doc])
     (v-append
      (nest 2 (v-append
               (hs-append (h-append (symtext symbol) colon) begin)
               doc)))])
  (module-pass : Module (m) -> * ()
    [(,[module-name-pass : doc0]
      (,[port-pass : doc1] ...)
      (,[operation-entry-pass : doc2] ...)
      (,[state-name-pass : doc3] ...)
      (,[declaration-pass : doc4] ...)
      (,[default-assign-pass : doc5] ...)
      (,[assign-state-pass : doc6] ...)
      (,[next-state-state-pass : doc7] ...))
     (v-append
      (nest 2 (v-append
               (hs-append module doc0 lparen)
               (v-concat (apply-infix comma doc1))))
      (nest 2 (v-append
               (with-semi rparen)
               (v-concat doc2)
               empty
               (v-concat doc3)
               empty
               (v-concat doc4)
               empty
               (v-append
                (nest 2 (v-append
                         (hs-append always (h-append at lparen (hs-append posedge clk) rparen) begin)
                         (v-concat doc5)
                         empty
                         (nest 2 (v-append
                                  (h-append case lparen next_state rparen)
                                  (v-concat doc6)
                                  (hs-append (h-append default colon) begin)
                                  end))
                         endcase))
                end)
               empty
               (v-append
                (nest 2 (v-append
                         (hs-append always (h-append at lparen (hs-append start or state) rparen) begin)
                         (nest 2 (v-append
                                  (h-append case lparen state rparen)
                                  (v-concat doc7)
                                  (nest 2 (v-append
                                           (hs-append (h-append default colon) begin)
                                           (with-semi (hs-append next_state equals state))))
                                  end))
                         endcase))
                end)))
      endmodule
      line)]))

(define adt-to-verilog
  (compose1
   pretty-format
   rtl-to-pprint
   add-boilerplate-states
   split-states
   add-state-names
   add-operation-entries
   add-default-assigns
   adjust-lowered-entries
   lower-module-calls
   add-port-binding-declarations
   store-module-bindings!
   add-module-port-bindings
   store-module-signature!
   add-boilerplate-ports
   add-ports))
