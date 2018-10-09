#lang s-exp "expander.rkt"

(controller
 test-b
 (test (op =) (reg b) (const 0))
 (branch (label gcd-done))
 (assign t (op remainder) (reg a) (reg b))
 (assign a (reg b))
 (assign b (reg t))
 (goto (label test-b))
 gcd-done)

;; (machine-set-register! machine 'a 35)
;; (machine-set-register! machine 'b 14)
;; (machine-start machine)
;; (machine-get-register machine 'a)
