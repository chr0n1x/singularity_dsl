# encoding: utf-8

require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/errors'
require 'singularity_dsl/runstate'

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # class that runs Singularity::Dsl
    class Runner
      include SingularityDsl::Errors

      attr_reader :state, :dsl

      def initialize
        @dsl = Dsl.new
        @state = Runstate.new
      end

      def execute(pass_errors = false)
        @dsl.registry.task_list.each do |task|
          task.execute.tap do |status|
            failed = task.failed_status status
            record_failure task if failed
            resource_fail task if failed && !pass_errors
          end
        end
      end

      def load_ex_script(path)
        @dsl.instance_eval(::File.read path)
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
end
