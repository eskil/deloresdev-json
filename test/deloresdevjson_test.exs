defmodule DeloresDevJSONTest do
  use ExUnit.Case

  test "NULL is parsed as nil" do
    assert {:ok, %{foo: nil}} = DeloresDevJSON.parse("foo: NULL")
    assert {:ok, [nil, nil, 1]} = DeloresDevJSON.parse("[NULL NULL 1]")
  end

  test "toplevel dict without curly braces" do
    input = "foo: 1\nbar: 2"
    assert {:ok, %{foo: 1, bar: 2}} = DeloresDevJSON.parse(input)
  end

  test "toplevel dict with curly braces" do
    input = "{foo: 1, bar: 2}"
    assert {:ok, %{foo: 1, bar: 2}} = DeloresDevJSON.parse(input)
  end

  # test "tuple of numbers" do
  #   input = "{1,2}"
  #   assert {:ok, {1, 2}} = DeloresDevJSON.parse(input)
  #   input = "{1,2,3}"
  #   assert {:ok, {1, 2, 3}} = DeloresDevJSON.parse(input)
  # end

  # test "tuple of numbers with spaces" do
  #   input = "{ 1 , 2 , 3 }"
  #   assert {:ok, {1, 2, 3}} = DeloresDevJSON.parse(input)
  # end

  # test "parses single dict with a tuple" do
  #   input = """
  #   foo: {0, 1}
  #   """
  #   assert {:ok, %{foo: {0, 1}}} = DeloresDevJSON.parse(input)
  # end

  test "parses single dict" do
    input = """
    foo: 1
    bar: \"baz\"
    """
    assert {:ok, %{foo: 1, bar: bar_val}} = DeloresDevJSON.parse(input)
    assert is_binary(bar_val)
    assert bar_val == "baz"
  end

  test "parses comments" do
    input = """
    // comment
    foo: 1
    /* another comment */
    bar: \"baz\"
    """
    assert {:ok, %{foo: 1, bar: bar_val}} = DeloresDevJSON.parse(input)
    assert is_binary(bar_val)
    assert bar_val == "baz"
  end

  test "parses dict with newlines as separators and string values are binaries" do
    input = """
    foo: \"hello\"
    bar: \"world\"
    baz: 3
    """
    assert {:ok, %{foo: foo_val, bar: bar_val, baz: 3}} = DeloresDevJSON.parse(input)
    assert is_binary(foo_val)
    assert is_binary(bar_val)
    assert foo_val == "hello"
    assert bar_val == "world"
  end

  test "list of numbers with commas" do
    input = "[1,2,3]"
    assert {:ok, [1, 2, 3]} = DeloresDevJSON.parse(input)
  end

  test "parses list with newlines as separators" do
    input = """
    [
      1
      2
      3
    ]
    """
    assert {:ok, [1, 2, 3]} = DeloresDevJSON.parse(input)
  end

  test "parse! returns value on success" do
    assert %{foo: 1} = DeloresDevJSON.parse!("foo: 1")
  end

  test "parse_file reads and parses a file successfully" do
    path = Path.join([:code.priv_dir(:deloresdevjson) |> to_string(), "tests/sample.json"])
    path = if File.exists?(path), do: path, else: "priv/tests/sample.json"

    assert {:ok, result} = DeloresDevJSON.parse_file(path)
    assert result[:sheet] == "Delores"
  end

  test "parse_file! returns value on success" do
    path = Path.join([:code.priv_dir(:deloresdevjson) |> to_string(), "tests/sample.json"])
    path = if File.exists?(path), do: path, else: "priv/tests/sample.json"

    result = DeloresDevJSON.parse_file!(path)
    assert result[:sheet] == "Delores"
  end

  test "parse returns parser syntax error" do
    assert {:error, {1, :deloresdevjson_parser, _msg}} = DeloresDevJSON.parse("{")
  end

  test "parse returns lexer error for illegal characters" do
    assert {:error, {:error, {1, :deloresdevjson_lexer, _reason}, 1}} =
             DeloresDevJSON.parse("@#$%")
  end

  test "parse! raises on syntax error" do
    assert_raise RuntimeError, ~r/DeloresDevJSON parse error/, fn ->
      DeloresDevJSON.parse!("{")
    end
  end

  test "parse_file returns error for missing file" do
    assert {:error, :enoent} = DeloresDevJSON.parse_file("/nonexistent/path/file.json")
  end

  test "parse_file! raises for missing file" do
    assert_raise RuntimeError, ~r/DeloresDevJSON parse file error/, fn ->
      DeloresDevJSON.parse_file!("/nonexistent/path/file.json")
    end
  end

  test "parses TestAnimation.json file" do
    path = Path.join([:code.priv_dir(:deloresdevjson) |> to_string(), "tests/sample.json"])
    # Fallback if priv_dir() doesn't work, use relative path
    content =
      if File.exists?(path), do: File.read!(path), else: File.read!("priv/tests/sample.json")

    assert {:ok, result} = DeloresDevJSON.parse(content)
    assert result[:sheet] == "Delores"
    assert is_list(result[:animations])
    assert length(result[:animations]) == 2

    anim1 = Enum.at(result[:animations], 0)
    assert anim1[:name] == "accusatory_point_end_right"
    assert length(anim1[:layers]) == 2
    layer1_body = Enum.at(anim1[:layers], 0)
    assert layer1_body[:name] == "body"
    assert layer1_body[:frames] == [
      "accusatory_point3",
      "accusatory_point2",
      "accusatory_point1"
    ]
    layer1_head = Enum.at(anim1[:layers], 1)
    assert layer1_head[:flags] == 1
    assert layer1_head[:name] == "head1"
    assert layer1_head[:frames] == ["rstand_head1"]

    anim2 = Enum.at(result[:animations], 1)
    assert anim2[:name] == "walk_right"
    assert length(anim2[:layers]) == 2
    layer2_body = Enum.at(anim2[:layers], 0)
    assert layer2_body[:name] == "body"
    assert length(layer2_body[:frames]) == 8
    assert layer2_body[:frames] == [
      "rwalk_body1", "rwalk_body2", "rwalk_body3", "rwalk_body4",
      "rwalk_body5", "rwalk_body6", "rwalk_body7", "rwalk_body8"
    ]
    assert length(layer2_body[:triggers]) == 8
    assert layer2_body[:triggers] == [nil, nil, "step", nil, nil, nil, "step", nil]

    layer2_head = Enum.at(anim2[:layers], 1)
    assert layer2_head[:flags] == 1
    assert layer2_head[:name] == "head1"
    assert length(layer2_head[:frames]) == 8
    assert Enum.all?(layer2_head[:frames], fn f -> f == "rstand_head1" end)
    assert length(layer2_head[:offsets]) == 8
    assert layer2_head[:offsets] == [
      "{0,1}", "{0,0}", "{0,-1}", "{0,0}", "{0,1}", "{0,0}", "{0,-1}", "{0,0}"
    ]
  end
end
