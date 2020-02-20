#lang nanopass

(require "rtl.rkt")

(define-parser rtl-parser rtl0)

;; numbers

(display
 (adt-to-verilog
  (rtl-parser
   '(number
     ()
     ((add
       ((in a (32 . 0))
        (in b (32 . 0))
        (out result))
       ((compute
         (((out result) (in a) (op +) (in b)))
         init))))))))

;; mux

(display
 (adt-to-verilog
  (rtl-parser
   '(signal
     ()
     ((mux
       ((in a (32 . 0))
        (in b (32 . 0))
        (in select)
        (out result (32 . 0)))
       ((compute
         ()
         (case (in select)
           (((const 1 b 0) out_a)
            ((const 1 b 1) out_b))
           init))
        (out_a
         (((out result) (in a)))
         init)
        (out_b
         (((out result) (in b)))
         init))))))))
