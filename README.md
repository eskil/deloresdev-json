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
* The parser is in `src/deloresdevjson_parser.yrl`.

---

## What is DeloresDevJSON?

DeloresDevJSON is a relaxed version of JSON used to describe sprite-sheet animations. It is not valid JSON or yaml. The main differences are

* Allows comments.
* Comma between elements optional when newlines are used.
* Unquoted keys parsed as atoms.
* Quoted keys parsed as strings.
* Top object doesn't need curly braces
* Supports `NULL` and tuples of numbers

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
| Tuple | `{1, 2}` | Braces containing **only numbers**<br>become an Erlang/Elixir tuple of numbers |

> **Dict vs. tuple disambiguation:** a `{…}` block is parsed as a *tuple* only when every element is a bare number. If any element is a non-number (string, ident, nested dict, etc.) it is treated as a dict.

---

## Elixir API

* `DeloresDevJSON.parse/1` parses a string and returns `{:ok, value}` or `{:error, reason}`.
* `DeloresDevJSON.parse!/1` parses a string; returns `value` or raises an exception on error.
* `DeloresDevJSON.parse_file/1` loads parses a file and returns `{:ok, value}` or `{:error, reason}`.
* `DeloresDevJSON.parse_file!/1` loads parses a file; returns `value` or raises an exception on error.

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

<table>
<tr>
<th>DeloresDevJSON `priv/sample.json`</th>
<th>Standard JSON</th>
</tr>
<tr>
<td>

```
// Delores animations
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

</td>
<td>

```json
{
  "sheet": "Delores",
  "animations": [
    {
      "name": "walk_right",
      "layers": [
        {
          "name": "body",
          "frames": [
            "rwalk_body1",
            "rwalk_body2",
            "rwalk_body3"
          ],
          "triggers": [
            "",
            "",
            "step"
          ]
        },
        {
          "flags": 1,
          "name": "head1",
          "frames": [
            "rstand_head1",
            "rstand_head1",
            "rstand_head1"
          ],
          "offsets": [
            "{0,1}",
            "{0,0}",
            "{0,-1}"
          ]
        }
      ]
    }
  ]
}
```

</td>
</tr>
</table>


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
