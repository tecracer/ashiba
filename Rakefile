require "rspec/core/rake_task"
require "bundler/gem_tasks"

# Remove unneeded tasks
Rake::Task["release"].clear

# We run tests by default
task :default => :test
task :gem => :build

#
# Install all tasks found in tasks folder
#
# See .rake files there for complete documentation.
#
Dir["tasks/*.rake"].each do |taskfile|
  load taskfile
end

namespace :lint do
  desc 'Linting for all markdown files'
  task :markdown do
    require 'mdl'

    MarkdownLint.run(%w[--verbose README.md CHANGELOG.md])
  end
end

require 'bump/tasks'
%w[set pre file current].each { |task| Rake::Task["bump:#{task}"].clear }
Bump.changelog = :editor
Bump.tag_by_default = true
