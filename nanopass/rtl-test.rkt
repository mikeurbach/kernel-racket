#lang nanopass

(require "rtl.rkt")

(define-parser rtl-parser rtl0)

;; Pair module example

(display
 (adt-to-verilog
  (rtl-parser
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
         init))))))))

;; Environment module example
(display
 (adt-to-verilog
  (rtl-parser
   '(environment
     ((reg env_ref (8 . 0))
      (reg list_ref (8 . 0))
      (reg tuple_ref (8 . 0))
      (reg tuple_car (8 . 0))
      (mod pair pair_instance))
     ((new
       ((in env_in (8 . 0))
        (out env_out (8 . 0)))
       ((alloc_env
         ((invoke (mod pair_instance) (op cons) (const 9 h 100) (in env_in) (out env_out)))
         init)))
      (bind
       ((in env_in (8 . 0))
        (in symbol (8 . 0))
        (in value (8 . 0)))
       ((alloc_tuple
         ((invoke (mod pair_instance) (op cons) (in symbol) (in value) (reg tuple_ref)))
         load_car)
        (load_car
         ((invoke (mod pair_instance) (op car) (in env_in) (reg list_ref)))
         alloc_list)
        (alloc_list
         ((invoke (mod pair_instance) (op cons) (reg tuple_ref) (reg list_ref) (reg list_ref)))
         update_car)
        (update_car
         ((invoke (mod pair_instance) (op set_car) (reg env_in) (reg list_ref)))
         init)))
      (lookup
       ((in env_in (8 . 0))
        (in symbol (8 . 0))
        (out value (8 . 0)))
       ((store_ref
         (((reg env_ref) (reg env_in))
          ((out value) (const 9 h 100)))
         load_ref_car)
        (load_ref_car
         ((invoke (mod pair_instance) (op car) (reg env_ref) (reg list_ref)))
         list_ref_check)
        (list_ref_check
         ()
         (case (reg list_ref)
           (((const 9 h 100) load_ref_cdr))
           load_list_car))
        (load_list_car
         ((invoke (mod pair_instance) (op car) (reg list_ref) (reg tuple_ref)))
         load_tuple_car)
        (load_tuple_car
         ((invoke (mod pair_instance) (op car) (reg tuple_ref) (reg tuple_car)))
         symbol_check)
        (symbol_check
         ()
         (case (reg tuple_car)
           (((in symbol) load_tuple_cdr))
           load_list_cdr))
        (load_list_cdr
         ((invoke (mod pair_instance) (op cdr) (reg list_ref) (reg list_ref)))
         list_ref_check)
        (load_tuple_cdr
         ((invoke (mod pair_instance) (op cdr) (reg tuple_ref) (out value)))
         init)
        (load_ref_cdr
         ((invoke (mod pair_instance) (op cdr) (reg env_ref) (reg env_ref)))
         env_ref_check)
        (env_ref_check
         ()
         (case (reg env_ref)
           (((const 9 h 100) init))
           load_ref_car)))))))))

;; Basic Assigns

;;;; Register Target, Register Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (reg bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (reg bar (7 . 0))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo (7 . 0)) (reg bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo (7 . 0)) (reg bar (7 . 0))))
         init))))))))

;;;; Register Target, Memory Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (mem ram (reg addr))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (mem ram (reg addr (7 . 0)))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo (7 . 0)) (mem ram (reg addr))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo (7 . 0)) (mem ram (reg addr (7 . 0)))))
         init))))))))

;;;; Register Target, Input Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (in bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (in bar (7 . 0))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo (7 . 0)) (in bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo (7 . 0)) (in bar (7 . 0))))
         init))))))))

;;;; Memory Target, Register Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo)) (reg bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo)) (reg bar (7 . 0))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo (7 . 0))) (reg bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo (7 . 0))) (reg bar (7 . 0))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (const 8 d 23)) (reg bar)))
         init))))))))

;;;; Memory Target, Memory Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo)) (mem ram (reg addr))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo)) (mem ram (reg addr (7 . 0)))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo (7 . 0))) (mem ram (reg addr))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo (7 . 0))) (mem ram (reg addr (7 . 0)))))
         init))))))))

;;;; Memory Target, Input Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo)) (in bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo)) (in bar (7 . 0))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo (7 . 0))) (in bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((mem ram (reg foo (7 . 0))) (in bar (7 . 0))))
         init))))))))

;;;; Output Target, Register Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo) (reg bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo) (reg bar (7 . 0))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo (7 . 0)) (reg bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo (7 . 0)) (reg bar (7 . 0))))
         init))))))))

;;;; Output Target, Memory Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo) (mem ram (reg addr))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo) (mem ram (reg addr (7 . 0)))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo (7 . 0)) (mem ram (reg addr))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo (7 . 0)) (mem ram (reg addr (7 . 0)))))
         init))))))))

;;;; Output Target, Input Value

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo) (in bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo) (in bar (7 . 0))))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo (7 . 0)) (in bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((out foo (7 . 0)) (in bar (7 . 0))))
         init))))))))

;; Unary Operator Assigns

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (op -) (reg bar)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (op ~) (reg bar)))
         init))))))))

;; Binary Operator Assigns

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (reg bar) (op +) (reg baz)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (reg bar) (op +) (const 8 d 1)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (reg bar) (op &) (reg baz)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (reg bar) (op &) (const 8 h ff)))
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         (((reg foo) (reg bar) (op \|) (const 8 b 11110000)))
         init))))))))

;; Next State

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         ()
         init))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         ()
         (case (in start)
           (((const 1 b 1) opcase))
           init)))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         ()
         (case (in op)
           (((const 2 d 0) op1)
            ((const 2 d 1) op2))
           init)))))))))

(display
 (adt-to-verilog
  (rtl-parser
   '(mod
     ()
     ((op1
       ()
       ((s1
         ()
         (case (in op)
           ((opsymbol1 op1)
            (opsymbol2 op2))
           init)))))))))
