# encoding: utf-8

# YEAH, THAT'S RIGHT
if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  throw 'Sorry, wont run on mswin|mingw32|windows'
end

require 'singularity_dsl/application'
require 'singularity_dsl/tasks'

# SingularityDsl module
# contains & create methods & environment for the .singularity.rb script
# any configurations or tasks specified by the script then get injected
# into SingularityDsl::Application
module SingularityDsl
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
    task_list.each { |klass| define_resource klass }
  end

  private

  def task_name(klass)
    klass.to_s.split(':').last
  end

  def resource(klass)
    task_name(klass).downcase.to_sym
  end

  def failed_status(status)
    ![nil, 0, false].include? status
  end

  def define_resource(klass)
    define_method(resource klass) do |&block|
      SingularityDsl::Application.instance.add_task klass.new(&block)
    end
  end
end
