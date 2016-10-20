require 'coveralls'
Coveralls.wear!
require "minitest/autorun"
require "editor_config"

class TestFnmatch < MiniTest::Test
  def test_fnmatch
    assert_fnmatch "Makefile", "Makefile"
    refute_fnmatch "Makefile", "Makefiler"
    refute_fnmatch "Makefile", "foo/Makefile"

    assert_fnmatch "foo/Makefile", "foo/Makefile"
    refute_fnmatch "foo/Makefile", "foo/Makefiler"
    refute_fnmatch "foo/Makefile", "Makefile"

    assert_fnmatch "/top/of/path", "/top/of/path"
    refute_fnmatch "/top/of/path", "top/of/path"
    assert_fnmatch "top/of/path", "top/of/path"
    refute_fnmatch "top/of/path", "/top/of/path"

    assert_fnmatch "*", "README"
    assert_fnmatch "*", "README.txt"
    assert_fnmatch "*", "README.md"
    refute_fnmatch "*", "docs/README"

    assert_fnmatch "foo/*/baz", "foo/bar/baz"
    refute_fnmatch "foo/*/baz", "foo/baz"
    refute_fnmatch "foo/*/baz", "foo/bar/bat"

    assert_fnmatch "Bar/*", "Bar/Foo"
    refute_fnmatch "Bar/*", "Bar/Foo/Baz"
    refute_fnmatch "Bar/*", "Bar"

    assert_fnmatch "a*e.c", "ace.c"
    assert_fnmatch "a*e.c", "ae.c"
    assert_fnmatch "a*e.c", "acce.c"
    refute_fnmatch "a*e.c", "bace.c"
    refute_fnmatch "a*e.c", "bae.c"

    assert_fnmatch "*.py", "foo.py"
    refute_fnmatch "*.py", "foo.txt"
    refute_fnmatch "*.py", "foo.pyc"
    refute_fnmatch "*.py", "foo"
    refute_fnmatch "*.py", "foo/bar.py"
    refute_fnmatch "*.py", "foo/bar.txt"
    refute_fnmatch "*.py", "foo/bar"

    assert_fnmatch "*.{js,py}", "foo.js"
    assert_fnmatch "*.{js,py}", "foo.py"
    refute_fnmatch "*.{js,py}", "foo.txt"
    refute_fnmatch "*.{js,py}", "foo.pyc"
    refute_fnmatch "*.{js,py}", "foo"
    refute_fnmatch "*.{js,py}", "foo/bar.js"
    refute_fnmatch "*.{js,py}", "foo/bar.py"
    refute_fnmatch "*.{js,py}", "foo/bar.pyc"
    refute_fnmatch "*.{js,py}", "foo/bar.txt"
    refute_fnmatch "*.{js,py}", "foo/bar"

    assert_fnmatch "[d-g].c", "d.c"
    assert_fnmatch "[d-g].c", "e.c"
    assert_fnmatch "[d-g].c", "f.c"
    assert_fnmatch "[d-g].c", "g.c"
    refute_fnmatch "[d-g].c", "c.c"
    refute_fnmatch "[d-g].c", "h.c"

    assert_fnmatch "lib/**.js", "lib/foo.js"
    assert_fnmatch "lib/**.js", "lib/foo/bar.js"
    assert_fnmatch "lib/**.js", "lib/foo/bar/baz.js"
    refute_fnmatch "lib/**.js", "foo.js"
    refute_fnmatch "lib/**.js", "lib/foo.py"

    assert_fnmatch "lib/**/foo.js", "lib/foo.js"
    assert_fnmatch "lib/**/foo.js", "lib/bar/foo.js"
    assert_fnmatch "lib/**/foo.js", "lib/bar/baz/foo.js"
    refute_fnmatch "lib/**/foo.js", "lib/bar.js"
    refute_fnmatch "lib/**/foo.js", "lib/bar/baz.js"

    assert_fnmatch "{some,a{*c,b}[ef]}.j", "some.j"
    assert_fnmatch "{some,a{*c,b}[ef]}.j", "abe.j"
    assert_fnmatch "{some,a{*c,b}[ef]}.j", "abf.j"
    assert_fnmatch "{some,a{*c,b}[ef]}.j", "ace.j"
    assert_fnmatch "{some,a{*c,b}[ef]}.j", "acf.j"
    assert_fnmatch "{some,a{*c,b}[ef]}.j", "abce.j"
    assert_fnmatch "{some,a{*c,b}[ef]}.j", "abcf.j"
    refute_fnmatch "{some,a{*c,b}[ef]}.j", "abg.j"
    refute_fnmatch "{some,a{*c,b}[ef]}.j", "acg.j"
    refute_fnmatch "{some,a{*c,b}[ef]}.j", "abcg.j"
    refute_fnmatch "{some,a{*c,b}[ef]}.j", "ae.j"
    refute_fnmatch "{some,a{*c,b}[ef]}.j", ".j"

    assert_fnmatch "{word,{also},this}.g", "word.g"
    assert_fnmatch "{word,{also},this}.g", "{also}.g"
    assert_fnmatch "{word,{also},this}.g", "this.g"
    refute_fnmatch "{word,{also},this}.g", "word,this}.g"
    refute_fnmatch "{word,{also},this}.g", "{also,this}.g"

    assert_fnmatch "{single}.b", "{single}.b"
    refute_fnmatch "{single}.b", ".b"
    refute_fnmatch "{single}.b", "single.b"

    assert_fnmatch "a{b,c,}.d", "a.d"
    assert_fnmatch "a{b,c,}.d", "ab.d"
    assert_fnmatch "a{b,c,}.d", "ac.d"
    refute_fnmatch "a{b,c,}.d", "a,.d"

    assert_fnmatch "{.f", "{.f"
    refute_fnmatch "{.f", ".f"
    assert_fnmatch "{}.c", "{}.c"
    refute_fnmatch "{}.c", ".c"

    assert_fnmatch "{{,b,c{d}.i", "{{,b,c{d}.i"
    refute_fnmatch "{{,b,c{d}.i", "{.i"
    refute_fnmatch "{{,b,c{d}.i", "b.i"
    refute_fnmatch "{{,b,c{d}.i", "c{d.i"
    refute_fnmatch "{{,b,c{d}.i", ".i"

    assert_fnmatch "{},b}.h", "{},b}.h"

    assert_fnmatch "{package.json,.travis.yml}", "package.json"
    assert_fnmatch "{package.json,.travis.yml}", ".travis.yml"
    refute_fnmatch "{package.json,.travis.yml}", "foo/package.json"
    refute_fnmatch "{package.json,.travis.yml}", "foo/.travis.yml"

    assert_fnmatch "ba?", "bar"
    assert_fnmatch "ba?", "baz"
    refute_fnmatch "ba?", "foo"
    refute_fnmatch "ba?", "bars"

    assert_fnmatch "ba[rz]", "bar"
    assert_fnmatch "ba[rz]", "baz"
    refute_fnmatch "ba[rz]", "foo"
    refute_fnmatch "ba[rz]", "bat"

    assert_fnmatch "ba[!tz]", "bar"
    refute_fnmatch "ba[!tz]", "foo"
    refute_fnmatch "ba[!tz]", "bat"
    refute_fnmatch "ba[!tz]", "baz"

    assert_fnmatch "[\\]ab].g", "].g"
    assert_fnmatch "[\\]ab].g", "a.g"
    assert_fnmatch "[\\]ab].g", "b.g"
    refute_fnmatch "[\\]ab].g", "c.g"
    refute_fnmatch "[\\]ab].g", "c].g"

    assert_fnmatch "[ab]].g", "a].g"
    assert_fnmatch "[ab]].g", "b].g"
    refute_fnmatch "[ab]].g", "c].g"

    assert_fnmatch "[!\\]ab].g", "c.g"
    refute_fnmatch "[!\\]ab].g", "].g"
    refute_fnmatch "[!\\]ab].g", "a.g"
    refute_fnmatch "[!\\]ab].g", "b.g"

    assert_fnmatch "[!ab]].g", "c].g"
    assert_fnmatch "[!ab]].g", "]].g"
    refute_fnmatch "[!ab]].g", "a].g"
    refute_fnmatch "[!ab]].g", "b].g"

    assert_fnmatch "{3..120}", "3"
    assert_fnmatch "{3..120}", "15"
    assert_fnmatch "{3..120}", "60"
    assert_fnmatch "{3..120}", "120"
    refute_fnmatch "{3..120}", "1"
    refute_fnmatch "{3..120}", "5a"
    refute_fnmatch "{3..120}", "121"
    refute_fnmatch "{3..120}", "060"

    assert_fnmatch "ab[e/]cd.i", "ab[e/]cd.i"
    refute_fnmatch "ab[e/]cd.i", "ab/cd.i"
    refute_fnmatch "ab[e/]cd.i", "abecd.i"

    assert_fnmatch "a**z.c", "a/z.c"
    assert_fnmatch "a**z.c", "amnz.c"
    assert_fnmatch "a**z.c", "am/nz.c"
    assert_fnmatch "a**z.c", "a/mnz.c"
    assert_fnmatch "a**z.c", "amn/z.c"
    assert_fnmatch "a**z.c", "a/mn/z.c"

    assert_fnmatch "b/**z.c", "b/z.c"
    assert_fnmatch "b/**z.c", "b/mnz.c"
    assert_fnmatch "b/**z.c", "b/mn/z.c"
    refute_fnmatch "b/**z.c", "bmnz.c"
    refute_fnmatch "b/**z.c", "bm/nz.c"
    refute_fnmatch "b/**z.c", "bmn/z.c"

    assert_fnmatch "c**/z.c", "c/z.c"
    assert_fnmatch "c**/z.c", "cmn/z.c"
    assert_fnmatch "c**/z.c", "c/mn/z.c"
    refute_fnmatch "c**/z.c", "cmnz.c"
    refute_fnmatch "c**/z.c", "cm/nz.c"
    refute_fnmatch "c**/z.c", "c/mnz.c"

    assert_fnmatch "d/**/z.c", "d/z.c"
    assert_fnmatch "d/**/z.c", "d/mn/z.c"
    refute_fnmatch "d/**/z.c", "dmnz.c"
    refute_fnmatch "d/**/z.c", "dm/nz.c"
    refute_fnmatch "d/**/z.c", "d/mnz.c"
    refute_fnmatch "d/**/z.c", "dmn/z.c"
  end

  def assert_fnmatch(pattern, path)
    assert EditorConfig.fnmatch?(pattern, path), "Expected #{pattern.inspect} to match #{path.inspect}."
  end

  def refute_fnmatch(pattern, path)
    refute EditorConfig.fnmatch?(pattern, path), "Expected #{pattern.inspect} not to match #{path.inspect}."
  end
end
