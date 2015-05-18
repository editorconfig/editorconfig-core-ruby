require "minitest/autorun"
require "editor_config"
require "stringio"

class TestParse < MiniTest::Test
  def fixture(name)
    path = File.join(__dir__, "fixtures/#{name}.in")
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

  def test_parse_example_file_io
    path = File.join(__dir__, "fixtures/sample.in")
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
    ], EditorConfig.parse(File.open(path)))
  end

  def test_parse_example_string_io
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
    ], EditorConfig.parse(StringIO.new(fixture(:sample))))
  end

  def test_parse_basic
    config, _ = EditorConfig.parse(fixture(:basic))
    assert_equal({
      "*.a" => {
        "option1" => "value1",
        "option2" => "value2"
      },
      "*.b" => {
        "option1" => "c",
        "option2" => "a"
      },
      "b.b" => {
        "option2" => "b"
      }
    }, config)
  end

  def test_parse_bom
    config, _ = EditorConfig.parse(fixture(:bom))
    assert_equal({
      "*" => {
        "key" => "value"
      }
    }, config)
  end

  def test_parse_crlf
    config, _ = EditorConfig.parse(fixture(:crlf))
    assert_equal({
      "*" => {
        "key" => "value"
      }
    }, config)
  end

  def test_parse_comments
    config, _ = EditorConfig.parse(fixture(:comments))
    assert_equal({
      "test1.c" => { "key" => "value" },
      "test2.c" => { "key" => "value" },
      "test3.c" => { "key" => "value" },
      "test4.c" => { "key1" => "value1", "key2" => "value2" },
      "test5.c" => { "key" => "value; not comment" },
      "test6.c" => { "key" => "value \\; not comment"},
      "test\\;.c" => { "key" => "value" },
      "test7.c" => { "key" => "value" },
      "test8.c" => { "key" => "value" },
      "test9.c" => { "key" => "value"},
      "test10.c" => { "key1" => "value1", "key2" => "value2" },
      "test11.c" => { "key" => "value# not comment" },
      "test12.c" => {"key" => "value \\# not comment" },
      "test\\#.c" => { "key" => "value" }
    }, config)
  end

  def test_parse_whitespace
    config, _ = EditorConfig.parse(fixture(:whitespace))
    assert_equal({
      "test1.c" => { "key" => "value" },
      "test2.c" => { "key" => "value" },
      "test3.c" => { "key" => "value" },
      "test4.c" => { "key" => "value" },
      "test5.c" => { "key" => "value" },
      "test6.c" => { "key1" => "value1", "key2" => "value2" },
      " test 7 " => { "key" => "value" },
      "test8.c" => { "key" => "value" },
      "test9.c" => { "key" => "value" },
      "test10.c" => { "key1" => "value1", "key2" => "value2", "key3" => "value3" },
      "test1.d" => { "key" => "value" },
      "test2.d" => { "key" => "value" },
      "test3.d" => { "key" => "value" },
      "test4.d" => { "key" => "value" },
      "test5.d" => { "key" => "value" }
    }, config)
  end

  def test_parse_max_section_name
    config, _ = EditorConfig.parse(fixture(:max_section_name))
    assert_equal [
      [100, 100],
      [500, 500],
      [500, 600]
    ], config.map { |name, value| [name.bytesize, value["length"].to_i] }
  end

  def test_parse_max_property_name
    config, _ = EditorConfig.parse(fixture(:max_property_name))
    assert_equal [
      [100, 100],
      [500, 500],
      [500, 600]
    ], config["Makefile"].map { |name, value| [name.bytesize, value.to_i] }
  end
end
