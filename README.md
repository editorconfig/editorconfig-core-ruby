# EditorConfig Ruby Core

EditorConfig Ruby Core provides the same functionality as the [EditorConfig C Core](https://github.com/editorconfig/editorconfig-core-c) and [EditorConfig Python Core](https://github.com/editorconfig/editorconfig-core-py) libraries.

## EditorConfig Project

EditorConfig makes it easy to maintain the correct coding style when switching between different text editors and between different projects. The EditorConfig project maintains a file format and plugins for various text editors which allow this file format to be read and used by those editors. For information on the file format and supported text editors, see the [EditorConfig website](http://editorconfig.org>).

## Installation

With RubyGems:

``` sh
$ gem install editorconfig
```

## Usage

Loading library module.

``` ruby
require 'editor_config'
EditorConfig.parse(File.read(".editorconfig"))
```

A command line binary is also provided.

```
$ editorconfig main.c
charset=utf-8
insert_final_newline=true
end_of_line=lf
tab_width=8
```

### Load

**File System**

An flattened config can be loaded from the file system with:

``` ruby
filename = "~/Project/foo/lib/foo.rb"
config = EditorConfig.load_file(filename)

# config: hash of properties and values
{
  "charset" => "utf-8",
  "indent_style" => "space",
  "end_of_line" => "lf",
  "insert_final_newline" => "true"
}
```

This API walks up the directory hierarchy gathering all `.editorconfig` files until it reaches a config that defines `root = true`.

**Custom Loader**

A custom loader can be provided to read files from another source rather than the file system.

For an example, you might load files directly from a git repository.

``` ruby
tree_sha, filename = "348b1ea52f897f313d62c56c2ba785a41f654861", "lib/foo.rb"

config = EditorConfig.load(filename) do |config_path|
  if blob_sha = `git ls-tree #{tree_sha} #{config_path}`.split(" ")[2]
    `git cat-file blob #{blob_sha}`
  end
end
```

### Parse

A low-level API for parsing an individual `.editorconfig` file.

A `[config, root]` tuple is returned. The `root` bit is set if a top-level `root = true` is seen. The `config` value is a two dimensional hash mapping section names to property names and values.

``` ruby
data = File.read(".editorconfig")
config, root = EditorConfig.parse(data)

# root: if top-most root = true flag is set
true

# config: hash of sections and properties
{
  "*" => {
    "end_of_line" => "lf",
    "insert_final_newline" => "true"
  },
  "*.{js,py}" => {
    "charset" => "utf-8"
  }
}
```


## Testing

[Cmake](http://www.cmake.org) is required to run the test suite. On OSX, just `brew install cmake`.

Then run the tests with:

``` sh
$ rake test
```
