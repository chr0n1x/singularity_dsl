# encoding: utf-8

require 'singularity_dsl/dsl'
require 'singularity_dsl/errors'
require 'singularity_dsl/runstate'

module SingularityDsl
  # class that runs Singularity::Dsl
  class DslRunner
    include SingularityDsl::Errors

    attr_reader :state

    def initialize(dsl = nil)
      dsl ||= Dsl.new
      @dsl = dsl
      @state = Runstate.new
      @ex_proc = proc {}
    end

    def execute(pass_errors)
      @ex_proc.call
      @dsl.registry.task_list.each do |task|
        task.execute.tap do |failed|
          record_failure task if task.failed_status failed
          resource_fail task if failed && !pass_errors
        end
      end
    end

    def load_ex_script(path)
      @ex_proc = proc { @dsl.instance_eval(::File.read path) }
    end

    def dsl(dsl)
      raise_dsl_set_err unless dsl.class <= Dsl
      @dsl = dsl
    end

    def post_actions
      @dsl.error_proc.call if @state.error
      @dsl.fail_proc.call if @state.failed
      @dsl.success_proc.call unless @state.failed || @state.error
      @dsl.always_proc.call
    end

    private

    def record_failure(task)
      @state.add_failure klass_failed(task)
    end

    def raise_dsl_set_err(dsl)
      fail "Invalid object given #{dsl}"
    end

    def execute_task(task)
      failed = false
      begin
        failed = task.execute
      rescue ::StandardError => err
        @state.add_error "#{err.message}\n#{err.backtrace}"
        resource_err task
      end
      failed
    end
  end
end
