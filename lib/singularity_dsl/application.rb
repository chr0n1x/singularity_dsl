# encoding: utf-8

require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/dsl/runner'
require 'singularity_dsl/errors'
require 'rainbow'

module SingularityDsl
  # application singleton - environment container for script
  class Application
    include SingularityDsl::Errors

    attr_reader :runner, :dsl

    def initialize
      @dsl = Dsl::Dsl.new
      @runner = Dsl::Runner.new
    end

    def load_script(script)
      dsl.load_ex_script script
    end

    def load_tasks(path)
      dsl.load_tasks_in_path path
    end

    def run(batch = false, pass_errors = false)
      begin
        @runner.execute dsl, batch, pass_errors
      # resource failed, :all_tasks not specified
      rescue ResourceFail => failure
        log_resource_fail failure
      # resource actually failed & threw error
      rescue ResourceError => error
        log_resource_error error
      ensure
        post_task_runner_actions
      end
      @runner.state.exit_code
    end

    def post_task_runner_actions
      script_warn @runner.state.failures if @runner.state.failed
      script_error @runner.state.errors if @runner.state.error
      @runner.post_actions(dsl)
    end

    def change_list(list)
      list = [*list]
      list.sort!
      dsl.changeset = list
    end

    private

    def log_resource_fail(failure)
      script_warn 'Script run failed!'
      script_warn failure.message
      failure.backtrace.each { |line| puts line }
    end

    def log_resource_error(error)
      script_error 'Script run error!'
      script_error error.message
      error.backtrace.each { |line| puts line }
    end

    def script_warn(message)
      puts Rainbow(message).yellow
    end

    def script_error(message)
      puts Rainbow(message).red
    end
  end
end
