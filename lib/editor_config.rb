require "editor_config/version"

module EditorConfig
  # Public: Default config basename.
  CONFIG_FILENAME = ".editorconfig".freeze

  # Public: Universal property names.
  #
  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties
  INDENT_STYLE             = "indent_style".freeze
  INDENT_SIZE              = "indent_size".freeze
  TAB_WIDTH                = "tab_width".freeze
  END_OF_LINE              = "end_of_line".freeze
  CHARSET                  = "charset".freeze
  TRIM_TRAILING_WHITESPACE = "trim_trailing_whitespace".freeze
  INSERT_FINAL_NEWLINE     = "insert_final_newline".freeze
  MAX_LINE_LENGTH          = "max_line_length".freeze

  # Public: Possible boolean values.
  #
  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties
  TRUE  = "true".freeze
  FALSE = "false".freeze

  # Public: Possible indent style values.
  #
  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#indent_style
  SPACE = "space".freeze
  TAB   = "tab".freeze

  # Public: Possible EOL values.
  #
  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#end_of_line
  CR   = "cr".freeze
  LF   = "lf".freeze
  CRLF = "crlf".freeze

  # Public: Possible charset values.
  #
  # https://github.com/editorconfig/editorconfig/wiki/EditorConfig-Properties#charset
  LATIN1    = "latin1".freeze
  UTF_8     = "utf-8".freeze
  UTF_8_BOM = "utf-8-bom".freeze
  UTF_16BE  = "utf-16be".freeze
  UTF_16LE  = "utf-16le".freeze

  # Internal: Default filename to use if path is too long or has too many
  # components.
  DEFAULT_FILENAME = "filename".freeze

  # Internal: Maximum byte length of filename path. Paths over this limit will
  # default to global "*" properties.
  MAX_FILENAME = 4096

  # Internal: Maximum number of directories a filename can have. Paths this
  # deep will default to global "*" properties.
  MAX_FILENAME_COMPONENTS = 25

  # Public: Parse the contents of an `.editorconfig`.
  #
  # io - An IO or String with the raw contents of an `.editorconfig` file.
  #
  # Returns a tuple of a parsed Hash of information and a boolean flag if the
  # file was marked as "root". The hash contains string keys of each section
  # of the config file.
  #
  # An example hash would look like this:
  # {
  #   "*.rb" => {
  #     "indent_style" => "space",
  #     "indent_size" => "2",
  #     "charset" => "utf-8"
  #   }
  # }
  #
  def self.parse(io, version: SPEC_VERSION)
    config, root = {}, false
    last_section = nil

    io.each_line do |line|
      line = line.sub(/\s+(;|#).+$/, "").chomp
      case line
      when /\Aroot(\s+)?\=(\s+)?true\Z/i
        root = true
      when /\A\s*\[(?<name>.{1,4096})\]\s*\Z/
        # section marker
        last_section = Regexp.last_match[:name]
        config[last_section] ||= {}
      when /\A\s*(?<name>[[:word:]]{1,50})\s*(\=|:)\s*(?<value>.{1,255})\s*\Z/
        match = Regexp.last_match
        name, value = match[:name].strip, match[:value].strip
        config[last_section][name] = value if last_section
      end
    end

    return config, root
  end

  # Public: Normalize known universal properties.
  #
  # config  - Hash configuration
  # version - String spec version
  #
  # Returns new preprocessed Hash.
  def self.preprocess(config, version: SPEC_VERSION)
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

    if version > "0.9"
      if !config.key?(INDENT_SIZE) && config[INDENT_STYLE] == TAB
        if config.key?(TAB_WIDTH)
          config[INDENT_SIZE] = config[TAB_WIDTH]
        else
          config[INDENT_SIZE] = TAB
        end
      end
    end

    config
  end

  # Internal: Temporary replacement constants used within fnmatch.
  FNMATCH_ESCAPED_LBRACE = "FNMATCH-ESCAPED-LBRACE".freeze
  FNMATCH_ESCAPED_RBRACE = "FNMATCH-ESCAPED-RBRACE".freeze

  # Public: Test shell pattern against a path.
  #
  # Modeled after editorconfig/fnmatch.py.
  #   https://github.com/editorconfig/editorconfig-core-py/blob/master/editorconfig/fnmatch.py
  #
  # pattern - String shell pattern
  # path    - String pathname
  #
  # Returns true if path matches pattern, otherwise false.
  def self.fnmatch?(pattern, path)
    flags = File::FNM_PATHNAME | File::FNM_EXTGLOB
    pattern = pattern.dup

    pattern.gsub!(/(\{\w*\})/) {
      $1.gsub("{", FNMATCH_ESCAPED_LBRACE).gsub("}", FNMATCH_ESCAPED_RBRACE)
    }
    pattern.gsub!(/(\{[^}]+$)/) {
      $1.gsub("{", FNMATCH_ESCAPED_LBRACE)
    }
    pattern.gsub!(/^([^\{]+\})/) {
      $1.gsub("}", FNMATCH_ESCAPED_RBRACE)
    }

    pattern.gsub!(/(\{(.*)\})/) {
      bracket = $1
      inner = $2

      if inner =~ /^(\d+)\.\.(\d+)$/
        "{#{($1.to_i..$2.to_i).to_a.join(",")}}"
      elsif inner.include?(",")
        bracket
      else
        "#{FNMATCH_ESCAPED_LBRACE}#{inner}#{FNMATCH_ESCAPED_RBRACE}"
      end
    }

    pattern.gsub!(FNMATCH_ESCAPED_LBRACE, "\\{")
    pattern.gsub!(FNMATCH_ESCAPED_RBRACE, "\\}")

    pattern.gsub!(/\[(.*\/.*)\]/) {
      "\\[#{$1}\\]"
    }

    patterns = []

    # Expand "**" to match over path separators
    # TODO: Optimize the number of patterns we need
    patterns << pattern.gsub(/\/\*\*/, "/**/*")
    patterns << pattern.gsub(/\/\*\*/, "")
    patterns << pattern.gsub(/\*\*/, "**/*")
    patterns << pattern.gsub(/\*\*/, "/**/*")

    patterns.any? { |p| File.fnmatch?(p, path, flags) }
  end

  # Public: Load EditorConfig with a custom loader implementation.
  #
  # path   - String filename on file system
  # config - Basename of config to search for (default: .editorconfig)
  #
  # loader block
  #   config_path - String "path/to/.editorconfig" to attempt to read from
  #
  # Returns Hash of String properties and values.
  def self.load(path, config: CONFIG_FILENAME, version: SPEC_VERSION)
    hash = {}

    # Use default filename if path is too long
    path = DEFAULT_FILENAME if path.length > MAX_FILENAME

    components = traverse(path)

    # Use default filename if path has too many directories
    path = DEFAULT_FILENAME if components.length > MAX_FILENAME_COMPONENTS

    components.each do |subpath|
      config_path = subpath == "" ? config : "#{subpath}/#{config}"
      config_data = yield config_path
      next unless config_data

      sections, root = parse(config_data, version: version)
      section_properties = {}

      sections.each do |section, properties|
        if section.include?("/")
          section = section[1..-1] if section[0] == "/"
          pattern = subpath == "" ? section : "#{subpath}/#{section}"
        else
          pattern = "**/#{section}"
        end

        if fnmatch?(pattern, path)
          section_properties.merge!(properties)
        end
      end

      hash = section_properties.merge(hash)

      if root
        break
      end
    end

    hash
  end

  # Internal: Generate subpaths for given path walking upwards to the root.
  #
  # path - String pathname
  #
  # Returns an Array of String paths.
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

  # Public: Load EditorConfig for a specific file.
  #
  # Starts at filename and walks up each directory gathering any .editorconfig
  # files until it reaches a config marked as "root".
  #
  # path   - String filename on file system
  # config - Basename of config to search for (default: .editorconfig)
  #
  # Returns Hash of String properties and values.
  def self.load_file(*args)
    EditorConfig.load(*args) do |path|
      File.read(path) if File.exist?(path)
    end
  end
end
