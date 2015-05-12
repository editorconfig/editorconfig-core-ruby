task :test do
  ENV["PATH"] = "#{__dir__}/bin:#{ENV["PATH"]}"

  cd "test/core-test"
  sh "cmake -DEDITORCONFIG_CMD=editorconfig ."
  sh "ctest ."
end
