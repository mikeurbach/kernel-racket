#lang nanopass

(require "rtl.rkt")

(define-parser rtl-adt-parser rtl-adt)

;; Pair module example

(adt-to-verilog
 (rtl-adt-parser
  '(pair
    ((mem cars (8 . 0) (255 . 0))
     (mem cdrs (8 . 0) (255 . 0))
     ((reg addr (7 . 0)) (const 8 d 1)))
    ((cons
      ((in car (8 . 0))
       (in cdr (8 . 0))
       (out pair_out (8 . 0)))
      ((cons0
        (((mem cars (reg addr)) (in car))
         ((mem cdrs (reg addr)) (in cdr))
         ((reg addr) (reg addr) (op +) (const 1 d 1))
         ((out pair_out) (const 1 b 1) (op \,) (reg addr)))
        init)))
     (car
      ((in pair_in (8 . 0))
       (out pair_out (8 . 0)))
      ((car0
        (((out pair_out) (mem cars (in pair_in (7 . 0)))))
        init)))
     (cdr
      ((in pair_in (8 . 0))
       (out pair_out (8 . 0)))
      ((cdr0
        (((out pair_out) (mem cdrs (in pair_in (7 . 0)))))
        init)))
     (set_car
      ((in pair_in (8 . 0))
       (in car (8 . 0)))
      ((set_car0
        (((mem cars (in pair_in (7 . 0))) (in car)))
        init)))
     (set_cdr
      ((in pair_in (8 . 0))
       (in cdr (8 . 0)))
      ((set_cdr0
        (((mem cdrs (in pair_in (7 . 0))) (in cdr)))
        init)))))))

;; Basic Assigns

;;;; Register Target, Register Value

(adt-to-verilog
 (rtl-adt-parser
  '(mod
    ()
    ((op1
      ()
      ((s1
        (((reg foo) (reg bar)))
        init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (reg bar (7 . 0))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo (7 . 0)) (reg bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo (7 . 0)) (reg bar (7 . 0))))
;;         init)))))))

;;;; Register Target, Memory Value

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (mem ram (reg addr))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (mem ram (reg addr (7 . 0)))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo (7 . 0)) (mem ram (reg addr))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo (7 . 0)) (mem ram (reg addr (7 . 0)))))
;;         init)))))))

;;;; Register Target, Input Value

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (in bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (in bar (7 . 0))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;        (((reg foo (7 . 0)) (in bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo (7 . 0)) (in bar (7 . 0))))
;;         init)))))))

;;;; Memory Target, Register Value

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo)) (reg bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo)) (reg bar (7 . 0))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo (7 . 0))) (reg bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo (7 . 0))) (reg bar (7 . 0))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (const 8 d 23)) (reg bar)))
;;         init)))))))

;;;; Memory Target, Memory Value

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo)) (mem ram (reg addr))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo)) (mem ram (reg addr (7 . 0)))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo (7 . 0))) (mem ram (reg addr))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo (7 . 0))) (mem ram (reg addr (7 . 0)))))
;;         init)))))))

;;;; Memory Target, Input Value

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo)) (in bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo)) (in bar (7 . 0))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo (7 . 0))) (in bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((mem ram (reg foo (7 . 0))) (in bar (7 . 0))))
;;         init)))))))

;;;; Output Target, Register Value

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo) (reg bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo) (reg bar (7 . 0))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo (7 . 0)) (reg bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo (7 . 0)) (reg bar (7 . 0))))
;;         init)))))))

;;;; Output Target, Memory Value

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo) (mem ram (reg addr))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo) (mem ram (reg addr (7 . 0)))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo (7 . 0)) (mem ram (reg addr))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo (7 . 0)) (mem ram (reg addr (7 . 0)))))
;;         init)))))))

;;;; Output Target, Input Value

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo) (in bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo) (in bar (7 . 0))))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo (7 . 0)) (in bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((out foo (7 . 0)) (in bar (7 . 0))))
;;         init)))))))

;; Unary Operator Assigns

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (op -) (reg bar)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (op ~) (reg bar)))
;;         init)))))))

;; Binary Operator Assigns

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (reg bar) (op +) (reg baz)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (reg bar) (op +) (const 8 d 1)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (reg bar) (op &) (reg baz)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (reg bar) (op &) (const 8 h ff)))
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         (((reg foo) (reg bar) (op \|) (const 8 b 11110000)))
;;         init)))))))

;; Next State

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         ()
;;         init)))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         ()
;;         (case (in start)
;;           ((const 1 b 1) opcase)
;;           init))))))))

;; (output-rtl
;;  (rtl-adt-parser
;;   '(mod
;;     ()
;;     ((op1
;;       ()
;;       ((s1
;;         ()
;;         (case (in op)
;;           ((const 2 d 0) op1)
;;           ((const 2 d 1) op2)
;;           init))))))))

;; Full Example

;; (output-rtl
;;  (rtl-adt-parser
;;   '(pair
;;     ((mem cars (8 . 0) (255 . 0))
;;      (mem cdrs (8 . 0) (255 . 0))
;;      (reg addr (8 . 0)))
;;     ((cons
;;       ((in car (8 . 0))
;;        (in cdr (8 . 0))
;;        (out pair (8 . 0)))
;;       ((cons0
;;         (((mem cars (reg addr)) (in car))
;;          ((mem cdrs (reg addr)) (in cdr))
;;          ((reg addr) (reg addr) (op +) (const 1 d 1))
;;          ((out pair) (const 1 b 1) (op \,) (reg addr)))
;;         init)))
;;      (car
;;       ((in pair (8 . 0))
;;        (out pair (8 . 0)))
;;       ((car0
;;         (((out pair) (mem cars (in pair (7 . 0)))))
;;         init)))
;;      (cdr
;;       ((in pair (8 . 0))
;;        (out pair (8 . 0)))
;;       ((cdr0
;;         (((out pair) (mem cdrs (in pair (7 . 0)))))
;;         init)))
;;      (set_car
;;       ((in pair (8 . 0))
;;        (in car (8 . 0)))
;;       ((set_car0
;;         (((mem cars (in pair (7 . 0))) (in car)))
;;         init)))
;;      (set_cdr
;;       ((in pair (8 . 0))
;;        (in cdr (8 . 0)))
;;       ((set_cdr0
;;         (((mem cdrs (in pair (7 . 0))) (in cdr)))
;;         init)))))))
