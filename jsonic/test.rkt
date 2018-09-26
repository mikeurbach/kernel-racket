#lang jsonic
[
  @$ 'null $@,
  @$ (* 6 7) $@,
  @$ (= 1 1) $@,
  @$ (list "array" "of" "strings") $@,
  // this is a comment
  @$ (hash
      'key-1 'null
      'key-2 (= 1 2)
      'key-3 (hash
              'subkey 21)) $@
]
