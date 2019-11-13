#lang racket

(require "verilog-printer.rkt" "port-printer.rkt")

(provide module-printer)

(define module-printer
  (class base-verilog-printer%
    (super-new)
    (init-field name)
    (init-field ports)

    (define default-inputs
      '((input "clk" ())
        (input "start" ())))

    (define default-outputs
      '((output "busy" ())))

    (define port-printers
      (map
       (lambda (port) (new port-printer [port port]))
       (append default-inputs ports default-outputs)))

    (define printed-ports
      (map
       (lambda (port-writer)
         (string-append
          "  "
          (send port-writer print)))
       port-printers))

    (define/override (do-print)
      (string-append
       "module "
       name
       " (\n"
       (string-join
        printed-ports
        ",\n")
       "\n); "
       "\nendmodule\n"))))
