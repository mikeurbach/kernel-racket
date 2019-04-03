#lang s-exp durin/vm

(assign foo (const 420))

(assign foo (const 420))
(assign bar (reg foo))
