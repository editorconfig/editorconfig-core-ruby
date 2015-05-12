require "rake/testtask"

task :test => ["test:unit", "test:integration"]

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.warning = true
  end

  task :integration => "test/core-test/.git" do
    ENV["PATH"] = "#{__dir__}/bin:#{ENV["PATH"]}"
    ENV["RUBYLIB"] = "#{__dir__}/lib:#{ENV["RUBYLIB"]}"

    cd "test/core-test"
    sh "cmake -DEDITORCONFIG_CMD=editorconfig ."
    sh "ctest ."
  end
end

file "test/core-test/.git" do
  sh "git submodule init"
  sh "git submodule update"
end
