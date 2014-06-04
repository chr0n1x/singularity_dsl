# encoding: utf-8

require 'singularity_dsl/runstate'
require 'singularity_dsl/tasks'

# SingularityDsl module
# Once included, loads any tasks & generates convenience
# functions to invoke them
module SingularityDsl
  def task_name(klass)
    klass.to_s.split(':').last
  end

  def task_to_sym(klass)
    task_name(klass).to_sym
  end

  def task_list
    klasses = []
    constants.each do |klass|
      klass = const_get(klass)
      next unless klass.is_a? Class
      next unless klass < Task
      klasses.push klass
    end
    klasses
  end

  def load_tasks
    task_list.each do |klass|
      define_method(task_to_sym klass) do |&block|
        Object.const_get(task_name klass).new(&block)
      end
    end
  end
end
