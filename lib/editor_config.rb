require "editor_config/version"
require "pathname"

module EditorConfig
  # Public: Parse a `.editorconfig` from a string.
  #
  # buffer - a String containing the contents of a `.editorconfig` file.
  #
  # Returns a hash of sections from the config file. Each section will be a
  # hash of key/value pairs for that section. The only top-level key that
  # won't have a Hash value is "root" which if it exists will be set to
  # `true`.
  #
  # Possible key/value pairs for sections are as follows:
  #   "indent_style"             - :tab, :space or nil.
  #   "indent_size"              - :tab, an integer between 1-64, or nil.
  #   "tab_width"                - an integer between 1-64, or nil.
  #   "end_of_line"              - :lf, :cr, :crlf or nil.
  #   "charset"                  - "latin1", "utf-8", "utf-8-bom", "utf-16be",
  #                                "utf-16le" or nil.
  #   "trim_trailing_whitespace" - true, false or nil.
  #   "insert_final_newline"     - true, false or nil.
  #
  # If either of these keys exist but the value is nil, the key existed in the
  # editorconfig but it's value was invalid or not supported.
  #
  # An example hash would look like this:
  # {
  #   "root" => true,
  #   "*.rb" => {
  #     "indent_style" => :space
  #     "indent_size" => 2,
  #     "charset" => "utf-8"
  #   }
  # }
  def self.parse(buffer)
    if !buffer.force_encoding("UTF-8").valid_encoding?
      raise ArgumentError, "editorconfig syntax must be valid UTF-8"
    end

    out_hash = {}
    last_section = nil

    buffer.each_line do |line|
      case line
      when /\Aroot(\s+)?\=(\s+)?true\Z/
        out_hash["root"] = true
      when /\A\[(?<name>[\/\{\},\*\.[:word:]]+)\]\Z/
        # section marker
        last_section = Regexp.last_match[:name]
        out_hash[last_section] = {}
      when /\A(?<name>[[:word:]]+)(\s+)?\=(\s+)?(?<value>.+)\Z/
        # name=value pair
        match = Regexp.last_match

        if last_section
          out_hash[last_section][match[:name]] = match[:value]
        else
          out_hash[match[:name]] = match[:value]
        end
      end
    end

    out_hash
  end

  def self.cast(name, value)
    case name
    when "indent_style" then cast_indent_style(value)
    when "indent_size" then cast_indent_size(value)
    when "tab_width" then cast_tab_width(value)
    when "end_of_line" then cast_end_of_line(value)
    when "charset" then cast_charset(value)
    when "trim_trailing_whitespace" then cast_trim_trailing_whitespace(value)
    when "insert_final_newline" then cast_insert_final_newline(value)
    end
  end

  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#indent_style
  def self.cast_indent_style(value)
    case value.to_s.downcase
    when "tab" then :tab
    when "space" then :space
    else nil
    end
  end

  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#indent_size
  def self.cast_indent_size(value)
    value = value.to_s.downcase
    if value == "tab"
      :tab
    elsif (value_int = value.to_i) && 0 < value_int && value_int < 64
      value_int
    else
      nil
    end
  end

  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#tab_width
  def self.cast_tab_width(value)
    if (value_int = value.to_i) && 0 < value_int && value_int < 64
      value_int
    else
      nil
    end
  end

  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#end_of_line
  def self.cast_end_of_line(value)
    case value.to_s.downcase
    when "lf" then :lf
    when "cr" then :cr
    when "crlf" then :crlf
    else nil
    end
  end

  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#charset
  def self.cast_charset(value)
    case value.to_s.downcase
    when "latin1" then "latin1"
    when "utf-8" then "utf-8"
    when "utf-8-bom" then "utf-8-bom"
    when "utf-16be" then "utf-16be"
    when "utf-16le" then "utf-16le"
    else nil
    end
  end

  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#trim_trailing_whitespace
  def self.cast_trim_trailing_whitespace(value)
    case value.to_s.downcase
    when "true" then true
    when "false" then false
    else nil
    end
  end

  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#insert_final_newline
  def self.cast_insert_final_newline(value)
    case value.to_s.downcase
    when "true" then true
    when "false" then false
    else nil
    end
  end

  def self.fnmatch?(pattern, path)
    File.fnmatch?(pattern, path, File::FNM_EXTGLOB) ||
      File.fnmatch?(pattern, File.basename(path), File::FNM_EXTGLOB)
  end

  def self.traverse(path)
    path = File.join("/", path)
    config = {}

    Pathname.new(path).dirname.ascend do |subpath|
      data = yield subpath.to_s
      next unless data

      ini = parse(data)

      ini.each do |pattern, properties|
        if fnmatch?(pattern, path)
          config = properties.merge(config)
        end
      end

      if ini["root"] == true
        break
      end
    end

    config
  end

  def self.fs_traverse(path, config: ".editorconfig")
    EditorConfig.traverse(path) do |path|
      config_path = File.join(path, config)
      File.read(config_path) if File.exist?(config_path)
    end
  end
end
