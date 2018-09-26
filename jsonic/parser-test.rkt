#lang br

(require jsonic/parser jsonic/tokenizer brag/support rackunit)

(check-equal?
 (parse-to-datum
  (apply-tokenizer-maker make-tokenizer "// this a comment\n"))
 '(jsonic-program))

(check-equal?
 (parse-to-datum
  (apply-tokenizer-maker make-tokenizer "@$ (* 6 7) $@"))
 '(jsonic-program
   (jsonic-sexp " (* 6 7) ")))

(check-equal?
 (parse-to-datum
  (apply-tokenizer-maker make-tokenizer "hi"))
 '(jsonic-program
   (jsonic-char "h")
   (jsonic-char "i")))
