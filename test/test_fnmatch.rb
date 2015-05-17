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

    assert_fnmatch "{single}.b", "{single}.b"
    refute_fnmatch "{single}.b", ".b"
    refute_fnmatch "{single}.b", "single.b"

    assert_fnmatch "{.f", "{.f"
    refute_fnmatch "{.f", ".f"

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

    # assert_fnmatch "ab[e/]cd.i", "ab[e/]cd.i"
    # refute_fnmatch "ab[e/]cd.i", "ab/cd.i"
    # refute_fnmatch "ab[e/]cd.i", "abecd.i"
  end

  def assert_fnmatch(pattern, path)
    assert EditorConfig.fnmatch?(pattern, path), "Expected #{pattern.inspect} to match #{path.inspect}."
  end

  def refute_fnmatch(pattern, path)
    refute EditorConfig.fnmatch?(pattern, path), "Expected #{pattern.inspect} not to match #{path.inspect}."
  end
end
