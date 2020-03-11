#lang brag

top: integer-literal | float-literal | string-literal | bare-id | bare-id-list | suffix-id | ssa-id | ssa-id-list | symbol-ref-id | caret-id

# literals
decimal-literal: DECIMAL_LITERAL
hexadecimal-literal: HEXADECIMAL_LITERAL
integer-literal: decimal-literal | hexadecimal-literal
float-literal: FLOAT_LITERAL
string-literal: STRING_LITERAL

# identifiers
bare-id: BARE_ID
bare-id-list: bare-id [/COMMA bare-id]*
suffix-id: SUFFIX_ID
ssa-id: /PERCENT suffix-id
ssa-id-list: ssa-id [/COMMA ssa-id]*
symbol-ref-id: /AMPERSAND (suffix-id | string-literal)
caret-id: /CARET suffix-id
