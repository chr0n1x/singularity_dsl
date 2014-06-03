#!/user/bin/env rake
# encoding: utf-8

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

namespace :test do

  RuboCop::RakeTask.new(:rubocop)

  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = '--format documentation --color'
  end

  desc 'Run RSpec with code coverage'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test:rspec'].execute
  end

  desc 'Run rubocop and rspec test'
  task all: [:rubocop, :rspec]
end
