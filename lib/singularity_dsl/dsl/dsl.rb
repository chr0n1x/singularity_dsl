# encoding: utf-8

require 'singularity_dsl/files'
require 'singularity_dsl/dsl/changeset'
require 'singularity_dsl/dsl/event_store'
require 'singularity_dsl/dsl/registry'
require 'singularity_dsl/dsl/utils'

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # wrapper for DSL
    class Dsl
      include Changeset
      include EventStore
      include Files
      include Utils

      attr_reader :registry

      def initialize
        super
        @registry = Registry.new
        load_tasks_in_path default_task_dir
      end

      def define_task(klass)
        raise_task_def_error klass if task_defined klass
        # because define_method is private
        define_singleton_method(task klass) do |&block|
          @registry.add_task klass.new(&block)
        end
      end

      def load_tasks_in_path(path)
        base_tasks = task_list
        files_in_path(path).each do |file|
          SingularityDsl.module_eval(::File.read file)
        end
        load_tasks(task_list - base_tasks)
      end

      def invoke_batch(name)
        @registry.add_batch_to_runlist name
      end

      def batch(name, &block)
        @registry.batch(name, self, &block)
      end

      private

      def raise_task_def_error(klass)
        fail "task name clash for #{klass}"
      end

      def task_defined(klass)
        singleton_methods(false).include?(task klass)
      end

      def load_tasks(list)
        list.each { |klass| define_task klass }
      end

      def default_task_dir
        dir = ::File.dirname __FILE__
        ::File.join dir, '..', 'tasks'
      end
    end
  end
end
