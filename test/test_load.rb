require 'coveralls'
Coveralls.wear!
require "minitest/autorun"
require "editor_config"

class TestLoad < MiniTest::Test
  def fixture(name)
    path = File.join(__dir__, "fixtures/#{name}.in")
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

  def test_max_filename
    # size: 1381
    subdir = ("a".."aaa").to_a.join("")

    paths = {
      ".editorconfig" => fixture(:sample2),
      "#{subdir}/.editorconfig" => fixture(:indent_styles)
    }

    global = {
      "charset" => "utf-8"
    }
    min = {
      "charset" => "utf-8",
      "indent_style" => "space"
    }
    full = {
      "indent_style" => "space",
      "indent_size" => "tab",
      "charset" => "utf-8"
    }

    assert_equal min, EditorConfig.load("space.txt") { |p| paths[p] }
    assert_equal full, EditorConfig.load("#{subdir}/space.txt") { |p| paths[p] }
    assert_equal global, EditorConfig.load("#{subdir}/#{subdir}/#{subdir}/#{subdir}/space.txt") { |p| paths[p] }
  end

  def test_max_filename_components
    short = ("a".."n").to_a.join("/")
    long = ("a".."z").to_a.join("/")

    paths = {
      ".editorconfig" => fixture(:sample2),
      "#{short}/.editorconfig" => fixture(:indent_styles)
    }

    global = {
      "charset" => "utf-8"
    }
    min = {
      "charset" => "utf-8",
      "indent_style" => "space"
    }
    full = {
      "indent_style" => "space",
      "indent_size" => "tab",
      "charset" => "utf-8"
    }

    assert_equal min, EditorConfig.load("space.txt") { |p| paths[p] }
    assert_equal full, EditorConfig.load("#{short}/space.txt") { |p| paths[p] }
    assert_equal global, EditorConfig.load("#{long}/space.txt") { |p| paths[p] }
  end
end
