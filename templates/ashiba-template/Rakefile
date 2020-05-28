require "rspec/core/rake_task"
require "bundler/gem_tasks"

Rake::Task["release"].clear

# We run tests by default
task :default => :build
task :gem => :build

#
# Install all tasks found in tasks folder
#
# See .rake files there for complete documentation.
#
Dir["tasks/*.rake"].each do |taskfile|
  load taskfile
end
