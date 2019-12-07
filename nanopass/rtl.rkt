#lang nanopass

(require pprint)

(provide
 rtl-adt
 adt-to-verilog)

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
  (RegisterDecl (register-decl)
    register
    (register value))
  (MemoryDecl (memory-decl)
    (mem symbol size0 size1))
  (Declaration (declaration)
    register-decl
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
      (let ([required-bits (exact-ceiling (log (length items) 2))])
        (if (> required-bits 1)
            (cons (- required-bits 1) 0)
            null)))
    (define (clk-port)
      (with-output-language (rtl-fsm Port)
        `(in clk)))
    (define (start-port)
      (with-output-language (rtl-fsm Port)
        `(in start)))
    (define (operation-port operations)
      (let ([size (required-size operations)])
        (with-output-language (rtl-fsm Port)
          (if (empty? size)
              `(in operation)
              `(in operation ,size)))))
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
          (if (empty? size)
              `(reg state)
              `(reg state ,size)))))
    (define (next-state-reg states)
      (let ([size (required-size states)])
        (with-output-language (rtl-fsm Declaration)
          (if (empty? size)
              `(reg next_state)
              `(reg next_state ,size)))))
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
     (let ([operation-entries (map operation-entry-pass operation-entry)]
           [augmented-state-names (append (boilerplate-state-names) state-name)])
       (let ([augmented-ports (append (boilerplate-ports operation-entries) port)]
             [augmented-declarations (append (boilerplate-declarations augmented-state-names) declaration)]
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
  (DefaultAssign (default-assign)
   (+ (symbol0 . symbol1)))
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
        (default-assign ...)
        (assign-state ...)
        (next-state-state ...)))))

(define-pass add-default-assigns : rtl-fsm (ast) -> rtl-preprint ()
  (definitions
    (define defaults
      (with-output-language (rtl-preprint DefaultAssign)
        (list
         `(state . next_state))))
    (define system-registers
      (set 'state 'next_state))
    (define (output? e)
      (nanopass-case (rtl-preprint Port) e
        [(out ,symbol) #t]
        [(out ,symbol ,size) #t]
        [else #f]))
    (define (register? e)
      (nanopass-case (rtl-preprint Declaration) e
        [(reg ,symbol) (not (set-member? system-registers symbol))]
        [(reg ,symbol ,size) (not (set-member? system-registers symbol))]
        [((reg ,symbol) ,value) (not (set-member? system-registers symbol))]
        [((reg ,symbol ,size) ,value) (not (set-member? system-registers symbol))]
        [else #f]))
    (define (extract-output e)
      (nanopass-case (rtl-preprint Port) e
        [(out ,symbol)
         (with-output-language (rtl-preprint DefaultAssign)
           `(,symbol . ,symbol))]
        [(out ,symbol ,size)
         (with-output-language (rtl-preprint DefaultAssign)
           `(,symbol . ,symbol))]))
    (define (extract-register e)
      (nanopass-case (rtl-preprint Declaration) e
        [(reg ,symbol)
         (with-output-language (rtl-preprint DefaultAssign)
           `(,symbol . ,symbol))]
        [(reg ,symbol ,size)
         (with-output-language (rtl-preprint DefaultAssign)
           `(,symbol . ,symbol))]
        [((reg ,symbol) ,value)
         (with-output-language (rtl-preprint DefaultAssign)
           `(,symbol . ,symbol))]
        [((reg ,symbol ,size) ,value)
         (with-output-language (rtl-preprint DefaultAssign)
           `(,symbol . ,symbol))])))
  (module-pass : Module (mo) -> Module ()
    [(,[module-name]
      (,[port] ...)
      (,[operation-entry] ...)
      (,[state-name] ...)
      (,[declaration] ...)
      (,[assign-state] ...)
      (,[next-state-state] ...))
     (let ([outputs (map extract-output (filter output? port))]
           [registers (map extract-register (filter register? declaration))])
       (let ([default-assigns (append defaults outputs registers)])
         `(,module-name
           (,port ...)
           (,operation-entry ...)
           (,state-name ...)
           (,declaration ...)
           (,default-assigns ...)
           (,assign-state ...)
           (,next-state-state ...))))]))

(define-pass preprint-to-pprint : rtl-preprint (ast) -> * ()
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
      (h-append
       (hs-append
        localparam
        (symtext symbol)
        equals
        (numtext (counter-proc)))
       semi))
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
                (h-append
                 (hs-append
                  next_state
                  equals
                  (symtext symbol))
                 semi)))
       end)))

  (module-name-pass : ModuleName (mn) -> * ()
    [,symbol (symtext symbol)])
  (input-pass : Input (i) -> * ()
    [(in ,symbol) (pprint-register input symbol null)]
    [(in ,symbol ,size) (pprint-register input symbol size)])
  (input-value-pass : Input (i) -> * ()
    [(in ,symbol) (symtext symbol)]
    [(in ,symbol ,size)
     (h-append
      (symtext symbol)
      (pprint-size size))])
  (output-pass : Output (i) -> * ()
    [(out ,symbol) (pprint-register output-reg symbol null)]
    [(out ,symbol ,size) (pprint-register output-reg symbol size)])
  (output-value-pass : Output (o) -> * ()
    [(out ,symbol) (symtext symbol)]
    [(out ,symbol ,size)
     (h-append
      (symtext symbol)
      (pprint-size size))])
  (port-pass : Port (p) -> * ()
    [,input (input-pass input)]
    [,output (output-pass output)])
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
     (h-append
      (symtext symbol)
      (pprint-size size))])
  (constant-pass : Constant (c) -> * ()
    [(const ,bitwidth ,baseident ,literal)
     (h-append
      (numtext bitwidth)
      squote
      (symtext baseident)
      (cond [(number? literal) (numtext literal)]
            [(symbol? literal) (symtext literal)]))])
  (memory-ref-pass : MemoryRef (mr) -> * ()
    [,register (register-value-pass register)]
    [,constant (constant-pass constant)]
    [,input (input-value-pass input)])
  (memory-pass : Memory (m) -> * ()
    [(mem ,symbol ,[memory-ref-pass : doc])
     (h-append
      (symtext symbol)
      lbracket
      doc
      rbracket)])
  (value-pass : Value (v) -> * ()
    [,symbol (symtext symbol)]
    [,register (register-value-pass register)]
    [,constant (constant-pass constant)]
    [,memory (memory-pass memory)]
    [,input (input-value-pass input)])
  (register-decl-pass : RegisterDecl (rd) -> * ()
    [,register (register-pass register)]
    [(,[register-pass : register] ,[value-pass : value])
     (hs-append
      register
      equals
      value)])
  (memory-decl-pass : MemoryDecl (md) -> * ()
    [(mem ,symbol ,size0 ,size1)
     (hs-append
      (pprint-register reg symbol size0)
      (pprint-size size1))])
  (declaration-pass : Declaration (d) -> * ()
    [,register-decl (h-append (register-decl-pass register-decl) semi)]
    [,memory-decl (h-append (memory-decl-pass memory-decl) semi)])
  (default-assign-pass : DefaultAssign (da) -> * ()
    [(,symbol0 . ,symbol1)
     (h-append
      (hs-append
       (symtext symbol0)
       assign
       (symtext symbol1))
      semi)])
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
     (h-append
      (hs-append
       doc0
       assign
       doc1)
      semi)]
    [(,[target-pass : doc0] ,[unary-op-pass : doc1] ,[value-pass : doc2])
     (h-append
      (hs-append
       doc0
       assign
       doc1
       doc2)
      semi)]
    [(,[target-pass : doc0] ,[value-pass : doc1] ,[binary-op-pass : doc2] ,[value-pass : doc3])
     (h-append
      (hs-append
       doc0
       assign
       (pprint-binop doc1 doc2 doc3))
      semi)])
  (assign-state-pass : AssignState (as) -> * ()
    [(,symbol (,[assign-pass : doc] ...))
     (v-append
      (nest 2 (v-append
               (hs-append
                (h-append
                 (symtext symbol)
                 colon)
                begin)
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
                         (h-append
                          (hs-append
                           next_state
                           equals
                           (symtext symbol0))
                          semi)))
                end)))
      endcase)])
  (next-state-pass : NextState (ns) -> * ()
    [,symbol
     (h-append
      (hs-append
       next_state
       equals
       (symtext symbol))
      semi)]
    [,case-statement (case-statement-pass case-statement)])
  (next-state-state-pass : NextStateState (nss) -> * ()
    [(,symbol ,[next-state-pass : doc])
     (v-append
      (nest 2 (v-append
               (hs-append
                (h-append
                 (symtext symbol)
                 colon)
                begin)
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
               (hs-append
                module doc0 lparen)
               (v-concat
                (apply-infix comma doc1))))
      (nest 2 (v-append
               (h-append rparen semi)
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
                                           (h-append (hs-append next_state equals state) semi)))
                                  end))
                         endcase))
                end)))
      endmodule
      line)]))

(define adt-to-verilog
  (compose1
   pretty-format
   preprint-to-pprint
   add-default-assigns
   add-boilerplate
   adt-to-fsm))
