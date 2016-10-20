require 'coveralls'
Coveralls.wear!
require "minitest/autorun"
require "editor_config"

class TestTraverse < MiniTest::Test
  def test_traverse
    assert_equal [
      "/"
    ], EditorConfig.traverse("/README")

    assert_equal [
      ""
    ], EditorConfig.traverse("README")

    assert_equal [
      "/usr/local/bin",
      "/usr/local",
      "/usr",
      "/"
    ], EditorConfig.traverse("/usr/local/bin/editorconfig")

    assert_equal [
      "lib/editor_config",
      "lib",
      ""
    ], EditorConfig.traverse("lib/editor_config/parser.rb")
  end
end
