#lang s-exp "expander.rkt"

(controller
 (goto (label read-eval-print-loop))

 eval-dispatch
 (test (op self-evaluating?) (reg exp))
 (branch (label ev-self-eval))
 (test (op variable?) (reg exp))
 (branch (label ev-variable))
 (test (op quoted?) (reg exp))
 (branch (label ev-quoted))
 (test (op assignment?) (reg exp))
 (branch (label ev-assignment))
 (test (op definition?) (reg exp))
 (branch (label ev-definition))
 (test (op if?) (reg exp))
 (branch (label ev-if))
 (test (op lambda?) (reg exp))
 (branch (label ev-lambda))
 (test (op begin?) (reg exp))
 (branch (label ev-begin))
 (test (op application?) (reg exp))
 (branch (label ev-application))
 (goto (label unknown-expression-type))

 ev-self-eval
 (assign val (reg exp))
 (goto (reg continue))

 ev-variable
 (assign val (op lookup-variable-value) (reg exp) (reg env))
 (goto (reg continue))

 ev-quoted
 (assign val (op text-of-quotation) (reg exp))
 (goto (reg continue))

 ev-lambda
 (assign unev (op lambda-parameters) (reg exp))
 (assign exp (op lambda-body) (reg exp))
 (assign val (op make-procedure) (reg unev) (reg exp) (reg env))
 (goto (reg continue))

 ev-application
 (save continue)
 (save env)
 (assign unev (op operands) (reg exp))
 (save unev)
 (assign exp (op operator) (reg exp))
 (assign continue (label ev-appl-did-operator))
 (goto (label eval-dispatch))

 ev-appl-did-operator
 (restore unev)                  ; the operands
 (restore env)
 (assign argl (op empty-arglist))
 (assign proc (reg val))         ; the operator
 (test (op no-operands?) (reg unev))
 (branch (label apply-dispatch))
 (save proc)

 ev-appl-operand-loop
 (save argl)
 (assign exp (op first-operand) (reg unev))
 (test (op last-operand?) (reg unev))
 (branch (label ev-appl-last-arg))
 (save env)
 (save unev)
 (assign continue (label ev-appl-accumulate-arg))
 (goto (label eval-dispatch))

 ev-appl-accumulate-arg
 (restore unev)
 (restore env)
 (restore argl)
 (assign argl (op adjoin-arg) (reg val) (reg argl))
 (assign unev (op rest-operands) (reg unev))
 (goto (label ev-appl-operand-loop))

 ev-appl-last-arg
 (assign continue (label ev-appl-accum-last-arg))
 (goto (label eval-dispatch))
 ev-appl-accum-last-arg
 (restore argl)
 (assign argl (op adjoin-arg) (reg val) (reg argl))
 (restore proc)
 (goto (label apply-dispatch))

 apply-dispatch
 (test (op primitive-procedure?) (reg proc))
 (branch (label primitive-apply))
 (test (op compound-procedure?) (reg proc))
 (branch (label compound-apply))
 (test (op compiled-procedure?) (reg proc))
 (branch (label compiled-apply))
 (goto (label unknown-procedure-type))

 primitive-apply
 (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
 (restore continue)
 (goto (reg continue))

 compound-apply
 (assign unev (op procedure-parameters) (reg proc))
 (assign env (op procedure-environment) (reg proc))
 (assign env (op extend-environment) (reg unev) (reg argl) (reg env))
 (assign unev (op procedure-body) (reg proc))
 (goto (label ev-sequence))

 compiled-apply
 (restore continue)
 (assign val (op compiled-procedure-entry) (reg proc))
 (goto (reg val))

 ev-begin
 (assign unev (op begin-actions) (reg exp))
 (save continue)
 (goto (label ev-sequence))

 ev-sequence
 (assign exp (op first-expr) (reg unev))
 (test (op last-expr?) (reg unev))
 (branch (label ev-sequence-last-exp))
 (save unev)
 (save env)
 (assign continue (label ev-sequence-continue))
 (goto (label eval-dispatch))

 ev-sequence-continue
 (restore env)
 (restore unev)
 (assign unev (op rest-exprs) (reg unev))
 (goto (label ev-sequence))

 ev-sequence-last-exp
 (restore continue)
 (goto (label eval-dispatch))

 ev-sequence
 (test (op no-more-exprs?) (reg unev))
 (branch (label ev-sequence-end))
 (assign exp (op first-expr) (reg unev))
 (save unev)
 (save env)
 (assign continue (label ev-sequence-continue))
 (goto (label eval-dispatch))
 ev-sequence-continue
 (restore env)
 (restore unev)
 (assign unev (op rest-exprs) (reg unev))
 (goto (label ev-sequence))
 ev-sequence-end
 (restore continue)
 (goto (reg continue))

 ev-if
 (save exp)                    ; save expression for later
 (save env)
 (save continue)
 (assign continue (label ev-if-decide))
 (assign exp (op if-predicate) (reg exp))
 (goto (label eval-dispatch))  ; evaluate the predicate

 ev-if-decide
 (restore continue)
 (restore env)
 (restore exp)
 (test (op true?) (reg val))
 (branch (label ev-if-consequent))

 ev-if-alternative
 (assign exp (op if-alternative) (reg exp))
 (goto (label eval-dispatch))

 ev-if-consequent
 (assign exp (op if-consequent) (reg exp))
 (goto (label eval-dispatch))

 ev-assignment
 (assign unev (op assignment-variable) (reg exp))
 (save unev)                   ; save variable for later
 (assign exp (op assignment-value) (reg exp))
 (save env)
 (save continue)
 (assign continue (label ev-assignment-1))
 (goto (label eval-dispatch))  ; evaluate the assignment value

 ev-assignment-1
 (restore continue)
 (restore env)
 (restore unev)
 (perform (op set-variable-value!) (reg unev) (reg val) (reg env))
 (assign val (const ok))
 (goto (reg continue))

 ev-definition
 (assign unev (op definition-variable) (reg exp))
 (save unev)                   ; save variable for later
 (assign exp (op definition-value) (reg exp))
 (save env)
 (save continue)
 (assign continue (label ev-definition-1))
 (goto (label eval-dispatch))  ; evaluate the definition value

 ev-definition-1
 (restore continue)
 (restore env)
 (restore unev)
 (perform (op define-variable!) (reg unev) (reg val) (reg env))
 (assign val (const ok))
 (goto (reg continue))

 read-eval-print-loop
 ;; (perform (op initialize-stack))
 (perform (op prompt-for-input) (const ";;; EC-Eval input:"))
 (assign exp (op read))
 (assign env (op get-global-environment))
 (assign continue (label print-result))
 (goto (label eval-dispatch))

 print-result
 (perform (op announce-output) (const ";;; EC-Eval value:"))
 (perform (op user-print) (reg val))
 ;; (perform (op announce-output) (const ";;; EC-Eval environment:"))
 ;; (perform (op user-print) (reg env))
 (goto (label read-eval-print-loop))

 unknown-expression-type
 (assign val (const unknown-expression-type-error))
 (goto (label signal-error))

 unknown-procedure-type
 (restore continue)    ; clean up stack (from apply-dispatch)
 (assign val (const unknown-procedure-type-error))
 (goto (label signal-error))

 signal-error
 (perform (op user-print) (reg val))
 (goto (label read-eval-print-loop))
)

;; (define (append x y)
;;   (if (empty? x)
;;       y
;;       (cons (car x) (append (cdr x) y))))
;; (append '(a b c) '(d e f))

;; (define (.* a b) (foldl + 0 (map * a b)))
;; (.* '(6 9 6) '(4 2 0))
;; map: contract violation
;;   expected: procedure?
;;   given: '(primitive #<procedure:*>)
;;
;; high-order functions not working...

;; (define (foldl+ l)
;;   (if (eq? (length l) 1)
;;       (car l)
;;       (foldl+ (cons (+ (car l) (cadr l)) (cddr l)))))
;; (define (zip* l1 l2)
;;   (if (eq? (length l1) 1)
;;       (* (car l1) (car l2))
;;       (flatten (cons (* (car l1) (car l2)) (zip* (cdr l1) (cdr l2))))))
;; (foldl+ (zip* '(1 2 5) '(1 2 5)))
;;
;; but first order functions do