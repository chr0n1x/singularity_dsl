# encoding: utf-8

require 'singularity_dsl'
require 'singularity_dsl/files'
require 'singularity_dsl/dsl/changeset'
require 'singularity_dsl/dsl/event_store'
require 'singularity_dsl/dsl/registry'
require 'singularity_dsl/dsl/utils'

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # wrapper for DSL
    class Dsl < EventStore
      include Changeset
      include Files
      include Utils

      attr_reader :registry, :flags

      def initialize
        super
        @registry = Registry.new
        @flags = {}
        load_tasks_in_path default_task_dir
      end

      def load_ex_proc(&block)
        @registry = Registry.new
        instance_eval(&block)
      end

      def load_ex_script(path)
        @registry = Registry.new
        instance_eval(::File.read path)
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
        updated_tasks = task_list
        files_in_path(path, 'rb').each do |file|
          SingularityDsl.module_eval(::File.read file)
          # keep a list of class => file mappings
          (task_list - updated_tasks).each do |klass|
            SingularityDsl.map_task_file klass, file
          end
          updated_tasks = task_list
        end
        load_tasks(task_list - base_tasks)
      end

      def invoke_batch(name)
        @registry.add_batch_to_runlist name
      end

      def batch(name, &block)
        @registry.batch(name, self, &block)
      end

      def flag(name, val = true)
        @flags[name.to_sym] = val
      end

      def flag?(flag)
        return @flags[flag.to_sym] if @flags.key? flag.to_sym
        false
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
