# encoding: utf-8

# YEAH, THAT'S RIGHT
if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  throw 'Sorry, wont run on mswin|mingw32|windows'
end

require 'singularity_dsl/runstate'
require 'singularity_dsl/tasks'

# SingularityDsl module
# Once included, loads any tasks & generates convenience
# functions to invoke them
module SingularityDsl
  def task_name(klass)
    klass.to_s.split(':').last
  end

  def resource(klass)
    task_name(klass).downcase.to_sym
  end

  def task_description(klass)
    if klass.constants.include? :DESCRIPTION
      desc = klass.const_get 'DESCRIPTION'
    end
    desc ||= "Run the #{task_name klass} task"
    desc
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
      define_method(resource klass) do |&block|
        klass.new(&block)
      end
    end
  end
end
