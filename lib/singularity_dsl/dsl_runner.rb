# encoding: utf-8

require 'singularity_dsl/dsl'
require 'singularity_dsl/dsl_generator'
require 'singularity_dsl/runstate'

module SingularityDsl
  # class that runs Singularity::Dsl
  class DslRunner
    attr_reader :state

    def initialize(dsl = nil)
      @dsl = dsl ||= Dsl.new
      @state = Runstate.new
      @ex_proc = proc {}
    end

    def execute
      @ex_proc.call
    end

    def load_ex_script(path)
      @ex_proc = Proc.new do
        @dsl.instance_eval(::File.read path)
      end
    end

    def dsl(dsl)
      raise_dsl_set_err unless dsl.class <= Dsl
      @dsl = dsl
    end

   #def execute(ignore_fails)
   #  @tasks.each do |task|
   #    failed = execute_task task
   #    @state.add_failure klass_failed(task) if task.failed_status failed
   #    # used exclusivly to just halt .singularity.rb script execution
   #    resource_fail task if failed && !ignore_fails
   #    failed
   #  end
   #end

    private

    def raise_dsl_set_err(dsl)
      raise RuntimeError, "Invalid object given #{dsl}"
    end

    def post_actions
      @error_proc.call if @state.error
      @fail_proc.call if @state.failed
      @success_proc.call unless @state.failed || @state.error
      @always_proc.call
    end

    def execute_task(task)
      begin
        return task.execute
      rescue ::StandardError => err
        @state.add_error "#{err.message}\n#{err.backtrace}"
        resource_err task
      end
    end
  end
end
