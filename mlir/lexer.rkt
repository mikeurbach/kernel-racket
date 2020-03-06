#lang racket

(require brag/support br-parser-tools/lex)
(require (prefix-in : br-parser-tools/lex-sre))

(define (tokenize input)
  (port-count-lines! input)
  (define mlir-lexer
    (lexer-src-pos
     [(:+ numeric)
      (token 'DECIMAL_LITERAL (string->number lexeme))]
     [(:: "0x" (:+ (:or numeric (char-range "a" "f") (char-range "A" "F"))))
      (token 'HEXADECIMAL_LITERAL lexeme)]
     [(:: (:? (:or "+" "-")) (:+ numeric) (:? ".") (:* numeric) (:? (:or "e" "E") (:? (:or "+" "-")) (:+ numeric)))
      (token 'FLOAT_LITERAL (string->number lexeme))]
     [(:: "\"" (:* (:~ "\""))  "\"")
      (token 'STRING_LITERAL (substring lexeme 1 (sub1 (string-length lexeme))))]))
  (define (next-token) (mlir-lexer input))
  next-token)
