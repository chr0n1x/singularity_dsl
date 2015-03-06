# encoding: utf-8

module SingularityDsl
  module Cli
    module Command
      # base command class
      # options are just a hash
      # (preferably passed in from Cli::Cli via Thor)
      class Command
        attr_reader :options

        def initialize(opts = {})
          @options = opts
        end

        def execute
          fail 'cannot execute a base Command'
        end

        def tasks_path
          return false unless task_path_exists
          expanded_path
        end

        private

        def given_path
          options[:task_path]
        end

        def expanded_path
          ::File.expand_path given_path
        end

        def task_path_exists
          !given_path.nil? && ::File.exist?(given_path)
        end
      end
    end
  end
end
