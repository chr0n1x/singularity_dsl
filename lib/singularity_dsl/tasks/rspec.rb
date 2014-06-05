# encoding: utf-8

require 'rspec'

module SingularityDsl
  # RSpec resource
  class RSpec < Task
    DESCRIPTION = 'Run RSpec tests. Uses RSpec::Core'

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
  end
end
