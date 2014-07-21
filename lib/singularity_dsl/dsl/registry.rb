# encoding: utf-8

require 'singularity_dsl/dsl/batch'
require 'singularity_dsl/task'

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # wrapper for DSL
    class Registry
      def initialize
        @task_list = []
        @batch_list = {}
      end

      def add_task(task)
        fail_non_type('Task', task) unless task.is_a? Task
        fail_raw_type('Task', task) unless task.class < Task
        @task_list.push task
      end

      def batch(name, context, &block)
        batch_exists(name) if @batch_list.key? name.to_sym
        batch = Batch.new(name.to_sym, context, &block)
        @batch_list[name.to_sym] = batch
      end

      def add_batch_to_runlist(name)
        batch_dne name unless @batch_list[name.to_sym]
        @batch_list[name.to_sym].execute
      end

      def run_list(batch = false)
        if batch
          @task_list = []
          add_batch_to_runlist batch
        end
        @task_list
      end

      private

      def batch_dne(name)
        fail "Cannot invoke batch '#{name}', does not exist"
      end

      def batch_exists(name)
        fail "A task batch with the name '#{name}' already exists"
      end

      def fail_non_type(type, task)
        fail "Non-#{type} given - #{task}"
      end

      def fail_raw_type(type, task)
        fail "Cannot use raw #{type} objects - #{task}"
      end
    end
  end
end
