#lang racket

(require
 "core.rkt"
 "src/library/base.rkt"
 )

;; by requiring core, we've overridden #%module-begin and #%top-interaction.
;; by requiring the library files, we've mutated the global environment used by core.
;; now we can simply provide the same #%module-begin and #%top-interaction from core,
;; and the compound combiners defined in the library are layered on top.

(provide #%module-begin #%top-interaction global-env)
