# encoding: utf-8

require 'rspec'

module SingularityDsl
  # RSpec resource
  class RSpec < Task
    attr_accessor :spec_dir, :config_file

    def initialize(&block)
      @spec_dir ||= './spec'
      @config_file ||= './.rspec'
      super &block
    end

    def execute
       ::RSpec::Core::Runner.run([@spec_dir])
    end

    def description
      'Run RSpec tests. Uses RSpec::Core'
    end

    def config_file(dir)
      @config_file = dir
    end

    def spec_dir(dir)
      @spec_dir = dir
    end

    def set_state
    end
  end
end
