# DeloresDevJSON Parser

[![GitHub CI](https://github.com/eskil/deloresdev-json/actions/workflows/elixir.yml/badge.svg)](https://github.com/eskil/deloresdev-json/actions/workflows/elixir.yml)
[![Coverage Status](https://coveralls.io/repos/github/eskil/deloresdev-json/badge.svg?branch=main)](https://coveralls.io/github/eskil/deloresdev-json?branch=main)
[![Last Updated](https://img.shields.io/github/last-commit/eskil/deloresdev-json.svg)](https://github.com/eskil/deloresdev-json/commits/master)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hex.pm Download Total](https://img.shields.io/hexpm/dt/deloresdev-json.svg?style=flat-square)](https://hex.pm/packages/deloresdev-json)
![Static Badge](https://img.shields.io/badge/ircv3-no-blue)


This contains the
[leex](https://www.erlang.org/doc/apps/parsetools/leex.html) lexer (`src/deloresdevjson_lexer.xrl`) and
[yecc](https://www.erlang.org/doc/apps/parsetools/yecc.html) grammar (`src/deloresdevjson_parser.yrl`) for parsing the DeloresJSON format used in
[DeloresDev](https://github.com/grumpygamer/DeloresDev) animation files.

The Elixir wrapper is `DeloresDevJSON` (`lib/deloresdevjson.ex`).

---

## What is DeloresDevJSON?

DeloresDevJSON is a relaxed, human-friendly superset of JSON used to describe sprite-sheet animations. It is not valid JSON, but shares its basic structure. The main differences are described below.

---

## Format rules

### Root object — no enclosing braces required

A top-level object does **not** need `{` `}` around it. The file can just be a flat list of `key: value` pairs:

```
sheet: "Delores"
animations: [...]
```

This is equivalent to `{ "sheet": "Delores", "animations": [...] }` in standard JSON.

### Separators are optional

Commas between list items or dict entries are **optional**. Newlines alone are sufficient:

```
// comma-separated (valid)
[1, 2, 3]

// newline-separated (also valid)
[
  1
  2
  3
]
```

### Unquoted keys

Object keys can be bare identifiers without quotes:

```
name: "walk_right"
flags: 1
```

### Values

| Type | Example | Notes |
|---|---|---|
| String | `"hello"` | Double-quoted; backslash escapes honoured |
| Integer | `42`, `-7` | |
| Float | `3.14`, `1e10` | |
| Identifier/atom | `true`, `foo` | Becomes an Erlang/Elixir atom |
| `NULL` | `NULL` | The special identifier `NULL` becomes `nil` |
| Dict | `{ key: value }` | Braces required for nested dicts |
| List | `[value, value]` | `[…]` |
| Tuple | `{1, 2}` | Braces containing **only numbers** — becomes an Erlang/Elixir tuple |

> **Dict vs. tuple disambiguation:** a `{…}` block is parsed as a *tuple* only when every element is a bare number. If any element is a non-number (string, ident, nested dict, etc.) it is treated as a dict.

### Comments

Both C-style comment forms are supported and ignored by the lexer:

```
// single-line comment

/* multi
   line comment */
```

---

## Elixir parse results

`DeloresDevJSON.parse/1` returns `{:ok, value}` or `{:error, reason}`:

| DeloresDevJSON type | Elixir/Erlang result |
|---|---|
| String | `binary()` |
| Integer | `integer()` |
| Float | `float()` |
| Identifier | `atom()` |
| `NULL` | `nil` |
| Dict / root object | `map()` with **atom** keys |
| List | `list()` |
| Numeric tuple | `tuple()` |

---

## Full example

Input file (`priv/tests/sample.json`):

```
sheet: "Delores"
animations: [
    {
        name: "walk_right"
        layers: [
            {
                name: "body"
                frames: [
                    "rwalk_body1"
                    "rwalk_body2"
                    "rwalk_body3"
                ]
                triggers: [
                    NULL
                    NULL
                    "step"
                ]
            }
            {
                flags: 1
                name: "head1"
                frames: [
                    "rstand_head1"
                    "rstand_head1"
                    "rstand_head1"
                ]
                offsets: [
                    "{0,1}"
                    "{0,0}"
                    "{0,-1}"
                ]
            }
        ]
    }
]
```

Parsed Elixir result:

```elixir
%{
  sheet: "Delores",
  animations: [
    %{
      name: "walk_right",
      layers: [
        %{
          name: "body",
          frames: ["rwalk_body1", "rwalk_body2", "rwalk_body3"],
          triggers: [nil, nil, "step"]
        },
        %{
          flags: 1,
          name: "head1",
          frames: ["rstand_head1", "rstand_head1", "rstand_head1"],
          offsets: ["{0,1}", "{0,0}", "{0,-1}"]
        }
      ]
    }
  ]
}
```

Note: `offsets` values are stored as plain strings (e.g. `"{0,1}"`) rather than tuples because they are quoted strings in the source file, not bare numeric tuples.
