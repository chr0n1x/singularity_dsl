# encoding: utf-8

require 'singularity_dsl/dsl_defaults'
require 'singularity_dsl/dsl_registry'

# default tasks should be loaded in here
require 'singularity_dsl/tasks'

module SingularityDsl
  # wrapper for DSL
  class Dsl
    include DslDefaults

    attr_reader :tasks, :registry

    def initialize
      @registry = DslRegistry.new
      @tasks = []
      load_base_tasks
    end

    def define_task(klass)
      raise_task_def_error klass if task_defined klass
      # because define_method is private
      define_singleton_method(task klass) do |&block|
        @registry.add_task klass.new(&block)
      end
      @tasks.push(task klass)
    end

    def task_name(klass)
      klass.to_s.split(':').last
    end

    def task_list
      klasses = []
      SingularityDsl.constants.each do |klass|
        klass = SingularityDsl.const_get(klass)
        next unless klass.is_a? Class
        next unless klass < Task
        klasses.push klass
      end
      klasses
    end

    private

    def raise_task_def_error(klass)
      fail "task name clash for #{klass}"
    end

    def task(klass)
      task_name(klass).downcase.to_sym
    end

    def task_defined(klass)
      singleton_methods(false).include?(task klass)
    end

    def load_base_tasks
      task_list.each { |klass| define_task klass }
    end
  end
end
