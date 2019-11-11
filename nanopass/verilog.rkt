#lang nanopass

(define-language module-specification
  (terminals
   (module-name (n)))
  (Module (m)
          (mod n)))

(define (module-name? n)
  (string? n))

(define-pass output-module : module-specification (ast) -> * ()
  (definitions
    (define (module-writer name)
      (display "module ")
      (display name)
      (display "; endmodule")))
  (Module : Module (m) -> * ()
          [(mod ,n) (module-writer n)]))
