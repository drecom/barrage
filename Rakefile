require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "pry console"
task :console do
  require "pry"
  require "barrage"
  binding.pry
end
