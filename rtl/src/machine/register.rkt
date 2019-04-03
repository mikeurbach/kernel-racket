#lang racket

(provide register register-value set-register-value!)
(struct register ([value #:mutable]))
