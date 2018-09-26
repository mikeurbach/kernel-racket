#lang br/quicklang

(require brag/support racket/contract)

(module+ test
  (require rackunit))

(define (make-tokenizer port)
  (port-count-lines! port)
  (define (next-token)
    (define jsonic-lexer
      (lexer
       [(eof) eof]
       [(from/to "//" "\n") (next-token)]
       [(from/to "@$" "$@")
        (token 'SEXP-TOKEN (trim-ends "@$" lexeme "$@")
               #:position (+ (pos lexeme-start) 2)
               #:line (line lexeme-start)
               #:column (+ (col lexeme-start) 2)
               #:span (- (pos lexeme-end)
                         (pos lexeme-start) 4))]
       [any-char (token 'CHAR-TOKEN lexeme
                        #:position (pos lexeme-start)
                        #:line (line lexeme-start)
                        #:column (col lexeme-start)
                        #:span (- (pos lexeme-end)
                                  (pos lexeme-start)))]))
    (jsonic-lexer port))
  next-token)

(module+ test
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "// this a comment\n")
   empty)
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "@$ (+ 6 7) $@")
   (list
    (token 'SEXP-TOKEN " (+ 6 7) "
           #:position 3
           #:line 1
           #:column 2
           #:span 9)))
  (check-equal?
   (apply-tokenizer-maker make-tokenizer "hi")
   (list
    (token 'CHAR-TOKEN "h"
           #:position 1
           #:line 1
           #:column 0
           #:span 1)
    (token 'CHAR-TOKEN "i"
           #:position 2
           #:line 1
           #:column 1
           #:span 1))))

(define (jsonic-token? tok)
  (or (eof-object? tok) (string? tok) (token-struct? tok)))

(module+ test
  (check-true (jsonic-token? eof))
  (check-true (jsonic-token? "token"))
  (check-true (jsonic-token? (token 'A-TOKEN "token")))
  (check-false (jsonic-token? 42)))

(provide (contract-out
          [make-tokenizer (input-port? . -> . (-> jsonic-token?))]))
