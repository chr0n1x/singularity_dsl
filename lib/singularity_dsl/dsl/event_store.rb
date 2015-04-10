# encoding: utf-8

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # default methods to for DSL objects
    class EventStore
      attr_reader :error_procs, :fail_procs, :success_procs, :always_procs

      def initialize
        @error_procs = []
        @fail_procs = []
        @success_procs = []
        @always_procs = []
      end

      def on_error(&block)
        @error_procs << ::Proc.new(&block)
      end

      def on_fail(&block)
        @fail_procs << ::Proc.new(&block)
      end

      def on_success(&block)
        @success_procs << ::Proc.new(&block)
      end

      def always(&block)
        @always_procs << ::Proc.new(&block)
      end
    end
  end
end
