#lang racket

(require brag/support br-parser-tools/lex)
(require (prefix-in : br-parser-tools/lex-sre))

(define (tokenize input)
  (port-count-lines! input)
  (define mlir-lexer
    (lexer-src-pos
     ["," (token 'COMMA lexeme)]
     [(:+ numeric)
      (token 'DECIMAL_LITERAL (string->number lexeme))]
     [(:: "0x" (:+ (:or numeric (char-range "a" "f") (char-range "A" "F"))))
      (token 'HEXADECIMAL_LITERAL lexeme)]
     [(:: (:? (:or "+" "-")) (:+ numeric) (:? ".") (:* numeric) (:? (:or "e" "E") (:? (:or "+" "-")) (:+ numeric)))
      (token 'FLOAT_LITERAL (string->number lexeme))]
     [(:: "\"" (:* (:~ "\"" "\n" "\f" "\v" "\r"))  "\"")
      (token 'STRING_LITERAL (substring lexeme 1 (sub1 (string-length lexeme))))]
     [(:: (:or "_" alphabetic) (:* (:or "_" "$" "." numeric alphabetic)))
      (token 'BARE_ID lexeme)]))
  (define (next-token) (mlir-lexer input))
  next-token)
