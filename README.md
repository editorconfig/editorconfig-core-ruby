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

## Testing

[Cmake](http://www.cmake.org) is required to run the test suite. On OSX, just `brew install cmake`.

Then run the tests with:

``` sh
$ rake test
```
