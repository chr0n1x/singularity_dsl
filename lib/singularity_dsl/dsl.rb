# encoding: utf-8

require 'singularity_dsl/dsl_defaults'

module SingularityDsl
  # wrapper for DSL
  class Dsl
    include DslDefaults

    attr_reader :tasks

    def initialize
      @tasks = []
    end

    def define_resource(klass)
      raise_resource_def_error klass if resource_defined klass 
      # because define_method is private
      define_singleton_method(resource klass) do |&block|
        klass.new(&block).execute
      end
      @tasks.push(resource klass)
    end

    private

    def raise_resource_def_error(klass)
      raise RuntimeError, "resource name clash for #{klass}"
    end

    def task_name(klass)
      klass.to_s.split(':').last
    end

    def resource(klass)
      task_name(klass).downcase.to_sym
    end

    def resource_defined(klass)
      singleton_methods(false).include?(resource klass)
    end
  end
end
