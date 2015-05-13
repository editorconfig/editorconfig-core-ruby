require "minitest/autorun"
require "editor_config"

class TestLoad < MiniTest::Test
  def fixture(name)
    path = File.join(__dir__, "fixtures/#{name}")
    File.read(path)
  end

  def test_load
    paths = {
      ".editorconfig" => fixture(:sample2),
      "docs/.editorconfig" => fixture(:indent_styles)
    }

    expected = {
      "charset" => "utf-8",
      "indent_style" => "space"
    }
    actual = EditorConfig.load("README.txt") { |p| paths[p] }
    assert_equal expected, actual

    expected = {
      "indent_style" => "space",
      "indent_size" => "4",
      "end_of_line" => "lf",
      "insert_final_newline" => "true",
      "trim_trailing_whitespace" => "true",
      "charset" => "utf-8"
    }
    actual = EditorConfig.load("README.rst") { |p| paths[p] }
    assert_equal expected, actual

    expected = {
      "indent_style" => "space",
      "indent_size" => "tab",
      "charset" => "utf-8"
    }
    actual = EditorConfig.load("docs/space.txt") { |p| paths[p] }
    assert_equal expected, actual

    expected = {
      "indent_style" => "tab",
      "charset" => "utf-8"
    }
    actual = EditorConfig.load("docs/tab.txt") { |p| paths[p] }
    assert_equal expected, actual
  end
end
