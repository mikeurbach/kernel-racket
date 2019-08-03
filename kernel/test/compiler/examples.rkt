#lang racket

(require "../../compiler.rkt")

'(($define! $second
    ($vau (first second) myenv
      second))

  ($second 1 2))
