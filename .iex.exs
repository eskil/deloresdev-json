project = Mix.Project.config()
app_name = project[:app] |> to_string() |> String.capitalize()
description = project[:description] |> to_string() |> String.capitalize()
version = project[:version] || "unknown"
config = project[:config_path]
title = "#{app_name} (v#{version})"
underline = String.duplicate("-", String.length(title))

IO.puts(IO.ANSI.format([:white, :bright, """

#{title}
#{underline}

#{description}

Try:
  DeloresDevJSON.parse_file('priv/tests/sample.json')
  DeloresDevJSON.parse_file!('priv/tests/sample.json')
"""], true))
