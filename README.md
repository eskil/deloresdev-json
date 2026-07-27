# DeloresDevJSON Parser

[![GitHub CI](https://github.com/eskil/deloresdev-json/actions/workflows/elixir.yml/badge.svg)](https://github.com/eskil/deloresdev-json/actions/workflows/elixir.yml)
[![Coverage Status](https://coveralls.io/repos/github/eskil/deloresdev-json/badge.svg?branch=main)](https://coveralls.io/github/eskil/deloresdev-json?branch=main)
[![Last Updated](https://img.shields.io/github/last-commit/eskil/deloresdev-json.svg)](https://github.com/eskil/deloresdev-json/commits/master)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Static Badge](https://img.shields.io/badge/ircv3-no-blue)


This contains a
[leex](https://www.erlang.org/doc/apps/parsetools/leex.html) lexer and
[yecc](https://www.erlang.org/doc/apps/parsetools/yecc.html) grammar for parsing the DeloresJSON format used in
[DeloresDev](https://github.com/grumpygamer/DeloresDev) animation files.

* The Elixir wrapper is `DeloresDevJSON`.
* The lexer is `src/deloresdevjson_lexer.xrl`.
* the parser is in `src/deloresdevjson_parser.yrl`.

---

## What is DeloresDevJSON?

DeloresDevJSON is a relaxed version of JSON used to describe sprite-sheet animations. It is not valid JSON, but shares its basic structure. The main differences are described below.

---

## Format rules

### Comments

Both C-style comment forms are supported and ignored by the lexer:

```json
// single-line comment

/* multi
   line comment */
```

### Unquoted keys

Object keys can be bare identifiers without quotes:

```json
name: "walk_right"
flags: 1
```

where standard json would be

```json
{
  "name": "walk_right",
  "flags": 1
}
```

### Separators are optional

Commas between list items or dict entries are **optional**. Newlines alone are sufficient:

```json
// comma-separated (valid)
[1, 2, 3]

// newline-separated (also valid)
[
  1
  2
  3
]
```

### Root object — no enclosing braces required

The top-level object does not need `{` `}` around it. The file can just be a flat list of `key: value` pairs:

<table>
  <tr>
    <th>DeloresDevJSON</th>
    <th>JSON</th>
  </tr>
  <tr>
    <td>
    ```json
    sheet: "Delores"
    animations: [...]
    ```
    </td>
    <td>
    ```json
    {
      "sheet": "Delores",
      "animations": [...]
    }
    ```
    </td>
  </tr>
</table>


In standard JSON, this would be

```json
```

### Number tuples

Tuples of numbers are parsed directly to elixir number tuples, while
DeloresDev JSON escapes these as strings, they're supported.

```json
offsets: [{0, 10}, {10, 10}]
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
| Tuple | `{1, 2}` | Braces containing **only numbers** — becomes an Erlang/Elixir tuple of numbers |

> **Dict vs. tuple disambiguation:** a `{…}` block is parsed as a *tuple* only when every element is a bare number. If any element is a non-number (string, ident, nested dict, etc.) it is treated as a dict.

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
                    {0,1}
                    {0,0}
                    {0,-1}
                ]
            }
        ]
    }
]
```

Parsed with

```elixir
DeloresDevJSON.parse_file!("priv/sample.json")
```

results in

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
          offsets: [{0, 1}, {0, 0}, {0, -1}]
        }
      ]
    }
  ]
}
```
