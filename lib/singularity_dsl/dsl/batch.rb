# encoding: utf-8

require 'singularity_dsl/task'

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # wrapper for a batch of tasks
    class Batch < Task
      attr_reader :name

      def initialize(name, context, &block)
        @name = name.to_sym
        @context = context
        @proc = block
      end

      def execute
        @context.instance_eval(&@proc)
      end
    end
  end
end
