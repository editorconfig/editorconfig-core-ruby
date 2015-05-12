file "test/core-test/.git" do
  sh "git submodule init"
  sh "git submodule update"
end

task :test => "test/core-test/.git" do
  ENV["PATH"] = "#{__dir__}/bin:#{ENV["PATH"]}"

  cd "test/core-test"
  sh "cmake -DEDITORCONFIG_CMD=editorconfig ."
  sh "ctest ."
end
