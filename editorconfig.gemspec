require_relative "lib/editor_config/version"

Gem::Specification.new do |s|
  s.name = "editorconfig"
  s.version = EditorConfig::VERSION
  s.summary = "EditorConfig core library written in Ruby"
  s.license = "MIT"
  s.authors = "GitHub"

  s.files = [
    "lib/editor_config.rb",
    "lib/editor_config/version.rb",
    "lib/editorconfig.rb"
  ]
end
