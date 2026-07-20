%% Grammar for a relaxed json format to parse DeloresDev files.

Nonterminals
  value dict dict_items dict_item list list_items tuple tuple_items key.

Terminals
  number string ident '[' ']' '{' '}' ':' ',' .

Rootsymbol value.

value -> dict : '$1'.
value -> dict_items : maps:from_list('$1').
value -> list : '$1'.
value -> tuple : '$1'.
value -> string : string_to_elixir('$1').
value -> number : number_to_elixir('$1').
value -> ident : ident_to_elixir('$1').

%% Dict: { key: value, ... }
dict -> '{' dict_items '}' : maps:from_list('$2').
dict_items -> dict_item : ['$1'].
dict_items -> dict_item ',' dict_items : ['$1' | '$3'].
dict_items -> dict_item dict_items : ['$1' | '$2'].
dict_item -> key ':' value : {'$1', '$3'}.

%% List: [ value, ... ]
list -> '[' list_items ']' : '$2'.
list_items -> value : ['$1'].
list_items -> value ',' list_items : ['$1' | '$3'].
list_items -> value list_items : ['$1' | '$2'].

%% Tuple: { number, ... }
tuple -> '{' tuple_items '}' : list_to_tuple('$2').
tuple_items -> number : [number_to_elixir('$1')].
tuple_items -> number ',' tuple_items : [number_to_elixir('$1') | '$3'].

key -> string : string_to_elixir('$1').
key -> ident : ident_to_elixir('$1').

% The Erlang code section (which is mandatory), is where you can add
% erlang functions you can call in the Definitions. In this case we
% have a to_token to create a token for each named variable (this is
% not good style, but just to show how to use the code section).

Erlang code.

string_to_elixir({string, _, S}) ->
  binary:list_to_bin(lists:sublist(S, 2, length(S)-2)).

number_to_elixir({number, _, N}) ->
  case string:to_float(N) of
    {error, _} -> list_to_integer(N);
    {F, _} -> F
  end.

ident_to_elixir({ident, _, I}) ->
  case I of
    "NULL" -> nil;
    _ -> list_to_atom(I)
  end.

list_to_tuple(L) -> list_to_tuple(L).
