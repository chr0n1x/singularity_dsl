# encoding: utf-8

require 'singularity_dsl/dsl'
require 'singularity_dsl/dsl_runner'
require 'singularity_dsl/errors'
require 'rainbow'

module SingularityDsl
  # application singleton - environment container for script
  class Application
    include SingularityDsl::Errors

    attr_reader :runner, :dsl

    def initialize
      @runner = DslRunner.new
      @dsl = Dsl.new
    end

    def load_script(script)
      @runner.load_ex_script script
    end

    def run(pass_errors = false)
      @runner.custom_dsl @dsl
      begin
        @runner.execute pass_errors
      # resource failed, :all_tasks not specified
      rescue ResourceFail => failure
        log_resource_fail failure
      # resource actually failed & threw error
      rescue ResourceError => error
        log_resource_error error
      ensure
        post_task_runner_actions
      end
    end

    def post_task_runner_actions
      script_warn @runner.state.failures if @runner.state.failed
      script_error @runner.state.errors if @runner.state.error
      @runner.post_actions
      exit_run
    end

    private

    def exit_run
      exit @runner.state.exit_code
    end

    def log_resource_fail(failure)
      script_warn 'Script run failed!'
      script_warn failure.message
      script_warn failure.backtrace
    end

    def log_resource_error(error)
      script_error 'Script run error!'
      script_error error.message
      script_error error.backtrace
    end

    def script_warn(message)
      puts Rainbow(message).yellow
    end

    def script_error(message)
      puts Rainbow(message).red
    end
  end
end
