# encoding: utf-8

require 'rspec'

# RSpec Task
class RSpec < Task
  attr_accessor :spec_dir, :config_file

  def initialize(&block)
    @spec_dir ||= './spec'
    @config_file ||= './.rspec'
    super(&block)
  end

  def config_file(file)
    validate_file file
    @config_file = file
  end

  def spec_dir(dir)
    validate_file dir
    @spec_dir = dir
  end

  def execute
    ::RSpec::Core::Runner.run([@spec_dir])
  end

  def description
    'Run RSpec tests. Uses RSpec::Core'
  end
end
