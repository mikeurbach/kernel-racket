#lang br

(require "struct.rkt" "line.rkt")
(provide run)

(define (run line-table)
  (define line-vec
    (list->vector (sort (hash-keys line-table) <)))
  (with-handlers ([end-program-signal? (lambda (exn-val) (void))])
    (for/fold ([line-idx 0])
              ([i (in-naturals)]
               #:break (>= line-idx (vector-length line-vec)))
      (define line-num (vector-ref line-vec line-idx))
      (define line-fun (hash-ref line-table line-num))
      (with-handlers
        ([change-line-signal?
          (lambda (cls)
            (define clsv (change-line-signal-val cls))
            (or
             (and (exact-positive-integer? clsv)
                  (vector-member clsv line-vec))
             (line-fun #:error (format "line ~a not found" clsv))))])
        (line-fun)
        (add1 line-idx)))))