# encoding: utf-8

require 'rubocop'

# Rubocop task
# Intentionally NOT a rake task - for some reason the syck YAML parser
# that Rubocop uses internally freaks out when a
# ::Rake::Application[:task].invoke is called from a task
class Rubocop < Task
  # :files     => specific files to run against
  # :cfg_file  => separate config file
  def initialize(&block)
    @default_config = './.rubocop.yml'
    @files = []
    @cfg_files = [@default_config]
    @cfg_store = ::RuboCop::ConfigStore.new
    super(&block)
  end

  def config_file(file)
    validate_file file

    return if @cfg_files.include? file
    warn 'Loading multiple configs' if File.exist? @default_config

    @cfg_files.push file

    # this does a merge of options...
    @cfg_store.options_config = file
  end

  def file(file)
    validate_file file
    @files.push file
  end

  def execute
    runner = ::RuboCop::Runner.new({}, @cfg_store)
    # returns true if all files passed, false otherwise
    !runner.run(files)
  end

  def description
    'Runs rubocop, loads .rubocop.yml from ./'
  end

  private

  def files
    ::RuboCop::TargetFinder.new(@cfg_store).find @files
  end
end
