require "editor_config/version"
require "pathname"

module EditorConfig
  INDENT_STYLE             = "indent_style".freeze
  INDENT_SIZE              = "indent_size".freeze
  TAB_WIDTH                = "tab_width".freeze
  END_OF_LINE              = "end_of_line".freeze
  CHARSET                  = "charset".freeze
  TRIM_TRAILING_WHITESPACE = "trim_trailing_whitespace".freeze
  INSERT_FINAL_NEWLINE     = "insert_final_newline".freeze
  MAX_LINE_LENGTH          = "max_line_length".freeze

  TRUE  = "true".freeze
  FALSE = "false".freeze

  SPACE = "space".freeze
  TAB   = "tab".freeze

  CR   = "cr".freeze
  LF   = "lf".freeze
  CRLF = "crlf".freeze

  LATIN1    = "latin1".freeze
  UTF_8     = "utf-8".freeze
  UTF_8_BOM = "utf-8-bom".freeze
  UTF_16BE  = "utf-16be".freeze
  UTF_16LE  = "utf-16le".freeze

  # Internal: Maximum number of bytes to read per line. Lines over this limit
  # will be truncated.
  MAX_LINE = 200

  # Internal: Maximum byte length of section name Strings. Names over this limit
  # will be truncated.
  MAX_SECTION_NAME = 500

  # Internal: Maximum byte length of property name String. Names over this limit
  # will be truncated.
  MAX_PROPERTY_NAME = 500

  # Public: Parse a `.editorconfig` from a string.
  #
  # io - a String containing the contents of a `.editorconfig` file.
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
  def self.parse(io)
    # if !io.force_encoding("UTF-8").valid_encoding?
    #   raise ArgumentError, "editorconfig syntax must be valid UTF-8"
    # end

    root = false
    out_hash = {}
    last_section = nil

    io.each_line do |line|
      case line
      when /\Aroot(\s+)?\=(\s+)?true\Z/
        root = true
      when /\A\[(?<name>[\/\{\},\*\.[:word:]]+)\]\Z/
        # section marker
        last_section = Regexp.last_match[:name][0, MAX_SECTION_NAME]
        out_hash[last_section] = {}
      when /\A(?<name>[[:word:]]+)(\s+)?\=(\s+)?(?<value>.+)\Z/
        match = Regexp.last_match
        name, value = match[:name][0, MAX_PROPERTY_NAME], match[:value]

        if last_section
          out_hash[last_section][name] = value
        else
          out_hash[name] = value
        end
      end
    end

    return out_hash, root
  end

  def self.preprocess(config)
    h = {}
    config.each do |key, value|
      v = cast_property(key, value)
      h[key] = v if !v.nil?
    end
    h
  end

  def self.cast_property(name, value)
    case name
    when INDENT_STYLE then cast_indent_style(value)
    when INDENT_SIZE then cast_indent_size(value)
    when TAB_WIDTH then cast_integer(value)
    when END_OF_LINE then cast_eol(value)
    when CHARSET then cast_charset(value)
    when TRIM_TRAILING_WHITESPACE then cast_boolean(value)
    when INSERT_FINAL_NEWLINE then cast_boolean(value)
    when MAX_LINE_LENGTH then cast_integer(value)
    end
  end

  def self.cast_indent_style(value)
    case value.to_s.downcase
    when TAB then TAB
    when SPACE then SPACE
    end
  end

  def self.cast_indent_size(value)
    case value.to_s.downcase
    when TAB then TAB
    else cast_integer(value)
    end
  end

  def self.cast_integer(value)
    value = value.to_i
    if 0 < value && value < 4096
      value
    end
  end

  def self.cast_eol(value)
    case value.to_s.downcase
    when LF then LF
    when CR then CR
    when CRLF then CRLF
    end
  end

  def self.cast_charset(value)
    case value.to_s.downcase
    when LATIN1 then LATIN1
    when UTF_8 then UTF_8
    when UTF_8_BOM then UTF_8_BOM
    when UTF_16BE then UTF_16BE
    when UTF_16LE then UTF_16LE
    end
  end

  def self.cast_boolean(value)
    case value.to_s.downcase
    when TRUE then true
    when FALSE then false
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

      ini, root = parse(data)

      ini.each do |pattern, properties|
        if fnmatch?(pattern, path)
          config = properties.merge(config)
        end
      end

      if root
        break
      end
    end

    config
  end

  def self.fs_traverse(path, config: ".editorconfig")
    EditorConfig.traverse(path) do |p|
      config_path = File.join(p, config)
      File.read(config_path) if File.exist?(config_path)
    end
  end
end
