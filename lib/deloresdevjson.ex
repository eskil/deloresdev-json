defmodule DeloresDevJSON do
  @moduledoc """
  Wrapper for the leex/yecc DeloresDevJSON parser.

  DeloresDevJSON is a JSON-like format used in DeloresDev for
  describing animations. See eg. [Delores.json](https://github.com/grumpygamer/DeloresDev/blob/master/Animation/DeloresAnimation.json).

  It's similar to JSON, but has some differences:
  * Doens't require opening/closing braces for the root element
  * Doesn't require commands between elements in lists or maps
  * Keys don't need to be quoted strings
  * ...

  Example usage
    DeloresDevJSON.parse(string)

  Returns Elixir data structures (maps, lists, tuples, numbers, strings, atoms).
  """

  @doc """
  Parse a DeloresDevJSON string. Returns {:ok, value} or {:error, reason}.
  """
  def parse(str) when is_binary(str) do
    charlist = String.to_charlist(str)
    with {:ok, tokens, _endline} <- :deloresdevjson_lexer.string(charlist),
         {:ok, value} <- :deloresdevjson_parser.parse(tokens) do
      {:ok, value}
    else
      {:error, {line, mod, msg}} -> {:error, {line, mod, msg}}
      error -> {:error, error}
    end
  end

  @doc """
  Parse a DeloresDevJSON string. Raises on error.
  """
  def parse!(str) do
    case parse(str) do
      {:ok, value} -> value
      {:error, reason} -> raise "DeloresDevJSON parse error: #{inspect(reason)}"
    end
  end
end
