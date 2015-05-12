require "minitest/autorun"
require "editor_config"

class TestEditorConfig < MiniTest::Test
  def test_parse_example
    config = <<-EOS.gsub(/^      /, "")
      # EditorConfig is awesome: http://EditorConfig.org

      # top-most EditorConfig file
      root = true

      # Unix-style newlines with a newline ending every file
      [*]
      end_of_line = lf
      insert_final_newline = true

      # Matches multiple files with brace expansion notation
      # Set default charset
      [*.{js,py}]
      charset = utf-8

      # 4 space indentation
      [*.py]
      indent_style = space
      indent_size = 4

      # Tab indentation (no size specified)
      [Makefile]
      indent_style = tab

      # Indentation override for all JS under lib directory
      [lib/**.js]
      indent_style = space
      indent_size = 2

      # Matches the exact files either package.json or .travis.yml
      [{package.json,.travis.yml}]
      indent_style = space
      indent_size = 2
    EOS

    assert_equal([
      {
        "*" => {
          "end_of_line" => "lf",
          "insert_final_newline" => "true"
        },
        "*.{js,py}" => {
          "charset" => "utf-8"
        },
        "*.py" => {
          "indent_style" => "space",
          "indent_size" => "4"
        },
        "Makefile" => {
          "indent_style" => "tab"
        },
        "lib/**.js" => {
          "indent_style" => "space",
          "indent_size" => "2"
        },
        "{package.json,.travis.yml}" => {
          "indent_style" => "space",
          "indent_size" => "2"
        }
      },
      true
    ], EditorConfig.parse(config))
  end

  def test_preprocess_indent_style
    assert_equal({ "indent_style" => "tab" },
      EditorConfig.preprocess({ "indent_style" => "tab" }))
    assert_equal({ "indent_style" => "space" },
      EditorConfig.preprocess({ "indent_style" => "space" }))
    assert_equal({ "indent_style" => "space" },
      EditorConfig.preprocess({ "indent_style" => "SPACE" }))
    assert_equal({},
      EditorConfig.preprocess({ "indent_style" => "emoji" }))
  end

  def test_preprocess_indent_size
    assert_equal({ "indent_size" => "tab" },
      EditorConfig.preprocess({ "indent_size" => "tab" }))
    assert_equal({ "indent_size" => 4 },
      EditorConfig.preprocess({ "indent_size" => "4" }))
    assert_equal({},
      EditorConfig.preprocess({ "indent_size" => "0" }))
    assert_equal({},
      EditorConfig.preprocess({ "indent_size" => "space" }))
  end

  def test_preprocess_tab_width
    assert_equal({ "tab_width" => 4 },
      EditorConfig.preprocess({ "tab_width" => "4" }))
    assert_equal({},
      EditorConfig.preprocess({ "tab_width" => "0" }))
  end

  def test_preprocess_end_of_line
    assert_equal({ "end_of_line" => "lf" },
      EditorConfig.preprocess({ "end_of_line" => "lf" }))
    assert_equal({ "end_of_line" => "crlf" },
      EditorConfig.preprocess({ "end_of_line" => "crlf" }))
    assert_equal({ "end_of_line" => "cr" },
      EditorConfig.preprocess({ "end_of_line" => "cr" }))
    assert_equal({ "end_of_line" => "crlf" },
      EditorConfig.preprocess({ "end_of_line" => "CRLF" }))
  end

  def test_preprocess_charset
    assert_equal({ "charset" => "latin1" },
      EditorConfig.preprocess({ "charset" => "latin1" }))
    assert_equal({ "charset" => "utf-8" },
      EditorConfig.preprocess({ "charset" => "utf-8" }))
    assert_equal({ "charset" => "utf-16be" },
      EditorConfig.preprocess({ "charset" => "utf-16be" }))
    assert_equal({ "charset" => "utf-16le" },
      EditorConfig.preprocess({ "charset" => "utf-16le" }))
    assert_equal({ "charset" => "utf-8" },
      EditorConfig.preprocess({ "charset" => "UTF-8" }))
  end

  def test_trim_trailing_whitespace
    assert_equal({ "trim_trailing_whitespace" => true },
      EditorConfig.preprocess({ "trim_trailing_whitespace" => "true" }))
    assert_equal({ "trim_trailing_whitespace" => false },
      EditorConfig.preprocess({ "trim_trailing_whitespace" => "false" }))
    assert_equal({ "trim_trailing_whitespace" => true },
      EditorConfig.preprocess({ "trim_trailing_whitespace" => "TRUE" }))
    assert_equal({},
      EditorConfig.preprocess({ "trim_trailing_whitespace" => "nil" }))
  end

  def test_insert_final_newline
    assert_equal({ "insert_final_newline" => true },
      EditorConfig.preprocess({ "insert_final_newline" => "true" }))
    assert_equal({ "insert_final_newline" => false },
      EditorConfig.preprocess({ "insert_final_newline" => "false" }))
    assert_equal({ "insert_final_newline" => true },
      EditorConfig.preprocess({ "insert_final_newline" => "TRUE" }))
    assert_equal({},
      EditorConfig.preprocess({ "insert_final_newline" => "nil" }))
  end

  def test_max_line_length
    assert_equal({ "max_line_length" => 80 },
      EditorConfig.preprocess({ "max_line_length" => "80" }))
    assert_equal({},
      EditorConfig.preprocess({ "max_line_length" => "0" }))
  end
end
