# encoding: utf-8

require 'singularity_dsl/dsl/batch'
require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/errors'
require 'singularity_dsl/runstate'

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # class that runs Singularity::Dsl
    class Runner
      include SingularityDsl::Errors

      attr_reader :state

      def initialize
        @state = Runstate.new
      end

      def execute(dsl = nil, batch = false, pass_errors = false)
        dsl ||= null_dsl
        dsl.registry.run_list(batch).each do |task|
          task.execute.tap do |status|
            failed = task.failed_status status
            record_failure task if failed
            resource_fail task if failed && !pass_errors
          end
        end
      end

      def post_actions(dsl = nil)
        dsl ||= null_dsl
        trigger_procs(dsl.error_procs) if @state.error
        trigger_procs(dsl.fail_procs) if @state.failed
        trigger_procs(dsl.success_procs) unless @state.failed || @state.error
        trigger_procs(dsl.always_procs)
      end

      private

      def null_dsl
        @dsl ||= Dsl::Dsl.new
      end

      def trigger_procs(procs)
        procs.each do |p|
          Dsl.new.tap { |dsl| execute dsl.instance_eval(&p) }
        end
      end

      def record_failure(task)
        failure = klass_failed(task)
        failure += " #{task.task_name}" if task.task_name
        @state.add_failure failure
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
end
