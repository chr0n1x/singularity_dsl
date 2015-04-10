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
        trigger_events(dsl.error_procs, dsl) if error?
        trigger_events(dsl.fail_procs, dsl) if failed?
        trigger_events(dsl.success_procs, dsl) if success?
        trigger_events(dsl.always_procs, dsl)
      end

      private

      def error?
        @state.error
      end

      def failed?
        @state.failed
      end

      def success?
        !(@state.failed || @state.error)
      end

      def null_dsl
        @dsl ||= Dsl::Dsl.new
      end

      def trigger_events(procs, context_dsl = nil)
        context_dsl ||= null_dsl
        procs.each do |p|
          context_dsl.load_ex_proc(&p)
          execute context_dsl
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
