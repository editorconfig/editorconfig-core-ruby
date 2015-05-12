require "minitest/autorun"
require "editor_config"

class TestEditorConfig < MiniTest::Test
  def fixture(name)
    path = File.join(__dir__, "fixtures/#{name}")
    File.read(path)
  end

  def test_parse_example
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
    ], EditorConfig.parse(fixture(:sample)))
  end

  def test_preprocess_indent_style
    config, _ = EditorConfig.parse(fixture(:indent_style))
    assert_equal({ "indent_style" => "tab" },
      EditorConfig.preprocess(config["test1"]))
    assert_equal({ "indent_style" => "space" },
      EditorConfig.preprocess(config["test2"]))
    assert_equal({ "indent_style" => "space" },
      EditorConfig.preprocess(config["test3"]))
    assert_equal({},
      EditorConfig.preprocess(config["test4"]))
  end

  def test_preprocess_indent_size
    config, _ = EditorConfig.parse(fixture(:indent_size))
    assert_equal({ "indent_size" => "tab" },
      EditorConfig.preprocess(config["test1"]))
    assert_equal({ "indent_size" => 4 },
      EditorConfig.preprocess(config["test2"]))
    assert_equal({},
      EditorConfig.preprocess(config["test3"]))
    assert_equal({},
      EditorConfig.preprocess(config["test4"]))
  end

  def test_preprocess_tab_width
    config, _ = EditorConfig.parse(fixture(:tab_width))
    assert_equal({ "tab_width" => 4 },
      EditorConfig.preprocess(config["test1"]))
    assert_equal({},
      EditorConfig.preprocess(config["test2"]))
  end

  def test_preprocess_end_of_line
    config, _ = EditorConfig.parse(fixture(:end_of_line))
    assert_equal({ "end_of_line" => "lf" },
      EditorConfig.preprocess(config["test1"]))
    assert_equal({ "end_of_line" => "crlf" },
      EditorConfig.preprocess(config["test2"]))
    assert_equal({ "end_of_line" => "cr" },
      EditorConfig.preprocess(config["test3"]))
    assert_equal({ "end_of_line" => "crlf" },
      EditorConfig.preprocess(config["test4"]))
  end

  def test_preprocess_charset
    config, _ = EditorConfig.parse(fixture(:charset))
    assert_equal({ "charset" => "latin1" },
      EditorConfig.preprocess(config["test1"]))
    assert_equal({ "charset" => "utf-8" },
      EditorConfig.preprocess(config["test2"]))
    assert_equal({ "charset" => "utf-16be" },
      EditorConfig.preprocess(config["test3"]))
    assert_equal({ "charset" => "utf-16le" },
      EditorConfig.preprocess(config["test4"]))
    assert_equal({ "charset" => "utf-8" },
      EditorConfig.preprocess(config["test5"]))
  end

  def test_trim_trailing_whitespace
    config, _ = EditorConfig.parse(fixture(:trim_trailing_whitespace))
    assert_equal({ "trim_trailing_whitespace" => true },
      EditorConfig.preprocess(config["test1"]))
    assert_equal({ "trim_trailing_whitespace" => false },
      EditorConfig.preprocess(config["test2"]))
    assert_equal({ "trim_trailing_whitespace" => true },
      EditorConfig.preprocess(config["test3"]))
    assert_equal({},
      EditorConfig.preprocess(config["test4"]))
  end

  def test_insert_final_newline
    config, _ = EditorConfig.parse(fixture(:insert_final_newline))
    assert_equal({ "insert_final_newline" => true },
      EditorConfig.preprocess(config["test1"]))
    assert_equal({ "insert_final_newline" => false },
      EditorConfig.preprocess(config["test2"]))
    assert_equal({ "insert_final_newline" => true },
      EditorConfig.preprocess(config["test3"]))
    assert_equal({},
      EditorConfig.preprocess(config["test4"]))
  end

  def test_max_line_length
    config, _ = EditorConfig.parse(fixture(:max_line_length))
    assert_equal({ "max_line_length" => 80 },
      EditorConfig.preprocess(config["test1"]))
    assert_equal({},
      EditorConfig.preprocess(config["test2"]))
  end
end
