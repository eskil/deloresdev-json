Definitions.
NUMBER     = [-+]?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?
IDENT      = [a-zA-Z_][a-zA-Z0-9_]*
STRING     = "([^"\\]|\\.)*"
WS         = [\s\t\n\r]+
COMMENT1   = //.*
COMMENT2   = /\*([^*]|\*+[^*/])*\*+/

Rules.
{NUMBER}        : {token, {number, TokenLine, TokenChars}}.
{STRING}        : {token, {string, TokenLine, TokenChars}}.
{IDENT}         : {token, {ident, TokenLine, TokenChars}}.
\[              : {token, {'[', TokenLine}}.
\]              : {token, {']', TokenLine}}.
\{              : {token, {'{', TokenLine}}.
\}              : {token, {'}', TokenLine}}.
:               : {token, {':', TokenLine}}.
,               : {token, {',', TokenLine}}.
{WS}            : skip_token.
{COMMENT1}      : skip_token.
{COMMENT2}      : skip_token.

% The Erlang code section (which is mandatory), is where you can add
% erlang functions you can call in the Definitions. In this case we
% have a to_token to create a token for each named variable (this is
% not good style, but just to show how to use the code section).

Erlang code.
