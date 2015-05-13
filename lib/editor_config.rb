require "editor_config/version"

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
      case line.chomp
      when /\Aroot(\s+)?\=(\s+)?true\Z/
        root = true
      when /\A\[(?<name>.+)\]\Z/
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
    config = config.reduce({}) { |h, (k, v)| h[k.downcase] = v; h }

    [
      INDENT_STYLE,
      INDENT_SIZE,
      TAB_WIDTH,
      END_OF_LINE,
      CHARSET,
      TRIM_TRAILING_WHITESPACE,
      INSERT_FINAL_NEWLINE,
      MAX_LINE_LENGTH
    ].each do |key|
      if config.key?(key)
        config[key] = config[key].downcase
      end
    end

    if !config.key?(TAB_WIDTH) && config.key?(INDENT_SIZE) && config[INDENT_SIZE] != TAB
      config[TAB_WIDTH] = config[INDENT_SIZE]
    end

    if !config.key?(INDENT_SIZE) && config[INDENT_STYLE] == TAB
      if config.key?(TAB_WIDTH)
        config[INDENT_SIZE] = config[TAB_WIDTH]
      else
        config[INDENT_SIZE] = TAB
      end
    end

    config
  end

  def self.fnmatch?(pattern, path)
    flags = File::FNM_PATHNAME | File::FNM_EXTGLOB
    File.fnmatch?(pattern, path, flags) ||
      File.fnmatch?(pattern, File.basename(path), flags)
  end

  def self.load(path, config: ".editorconfig")
    hash = {}

    traverse(path).each do |subpath|
      config_path = subpath == "" ? config : "#{subpath}/#{config}"
      config_data = yield config_path
      next unless config_data

      ini, root = parse(config_data)

      ini.each do |pattern, properties|
        matcher = subpath == "" ? pattern : "#{subpath}/#{pattern}"
        if fnmatch?(matcher, path)
          hash = properties.merge(hash)
        end
      end

      if root
        break
      end
    end

    hash
  end

  def self.traverse(path)
    paths = []
    parts = path.split("/", -1)

    idx = parts.length - 1

    while idx > 0
      paths << parts[0, idx].join("/")
      idx -= 1
    end

    if path.start_with?("/")
      paths[-1] = "/"
    else
      paths << ""
    end

    paths
  end

  def self.load_file(*args)
    EditorConfig.load(*args) do |path|
      File.read(path) if File.exist?(path)
    end
  end
end
