# encoding: utf-8

require 'singularity_dsl/dsl'
require 'singularity_dsl/tasks'

module SingularityDsl
  # wrapper logic to inject task definitions into a DSL
  class DslGenerator
    attr_reader :dsl

    def initialize
      @dsl = Dsl.new
      load_base_tasks
    end

    private

    def load_base_tasks
      task_list.each { |klass| @dsl.define_resource klass }
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
  end
end
