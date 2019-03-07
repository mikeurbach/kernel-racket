#lang s-exp kernel/core

(check-eq? ($if #t 1 2) 1)
(check-eq? ($if #f 1 2) 2)
