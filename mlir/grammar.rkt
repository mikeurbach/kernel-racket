#lang brag

top: integer-literal | float-literal | string-literal

decimal-literal: DECIMAL_LITERAL
hexadecimal-literal: HEXADECIMAL_LITERAL
integer-literal: decimal-literal | hexadecimal-literal
float-literal: FLOAT_LITERAL
string-literal: STRING_LITERAL

