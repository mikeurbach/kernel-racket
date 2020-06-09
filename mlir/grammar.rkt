#lang brag

top: operation

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

# ssa uses
ssa-use: ssa-id
ssa-use-list: ssa-use [/COMMA ssa-use]*

# operations
operation: [op-result-list] generic-operation [trailing-location]
generic-operation: string-literal /LPAREN [ssa-use-list] /RPAREN [successor-list] [/LPAREN region-list /RPAREN] [attribute-dict] /COLON function-type
# TODO: what about custom operations?
op-result-list: op-result [/COMMA op-result]* EQUALS
op-result: ssa-id /COLON integer-literal
successor-list: successor [/COMMA successor]*
successor: caret-id [/COMMA bb-arg-list]
region-list: region [/COMMA region]*
trailing-location: LOC /LPAREN location /RPAREN

# types
type: type-alias | dialect-type | standard-type
type-list-no-parens: type [/COMMA type]
type-list-parens: /LPAREN /RPAREN | /LPAREN type-list-no-parens /RPAREN

ssa-use-and-type: ssa-use /COLON type
ssa-use-and-type-list: 
