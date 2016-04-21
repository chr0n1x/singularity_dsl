# encoding: utf-8

require 'singularity_dsl/application'
require 'singularity_dsl/cli/command/command'
require 'singularity_dsl/stdout'

module SingularityDsl
  module Cli
    module Command
      # base command that runs application instances
      class AppRunnerCommand < Command
        include SingularityDsl::Stdout

        def initialize_app
          SingularityDsl::Application.new.tap do |app|
            inject_flags app, user_flags
            if tasks_path
              info "Loading tasks from #{tasks_path}"
              app.load_tasks tasks_path
            end
            info "Loading CI script from #{singularity_script} ..."
            app.load_script singularity_script
          end
        end

        private

        def user_flags
          options[:flags] || []
        end

        def script
          options[:script]
        end

        def script_path_exists?
          !script.nil? && ::File.exist?(script)
        end

        def singularity_script
          raise "Invalid script given: #{script}" unless script_path_exists?
          ::File.expand_path script
        end

        def inject_flags(app, flags = [])
          flags.each do |pair|
            key = pair.split(':', 2).first
            val = pair.split(':', 2).last
            app.dsl.flag key if key == val
            app.dsl.flag key, val unless key == val
          end
        end
      end
    end
  end
end
