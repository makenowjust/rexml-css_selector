# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"
require "rubocop/rake_task"
require "syntax_tree/rake_tasks"

Minitest::TestTask.create

RuboCop::RakeTask.new { |t| t.options = %w[--fail-level W] }

[SyntaxTree::Rake::WriteTask, SyntaxTree::Rake::CheckTask].each do |task|
  task.new do |t|
    t.source_files = FileList[%w[Gemfile Rakefile *.gemspec bin/**/{console,rake} lib/**/*.rb test/**/*.rb]]
    t.print_width = 120
  end
end

task format: %w[rubocop:autocorrect_all stree:write]
task lint: %w[rubocop stree:check]
