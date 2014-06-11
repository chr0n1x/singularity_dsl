# encoding: utf-8

require 'singularity_dsl/dsl_defaults'
require 'singularity_dsl/task'

module SingularityDsl
  # wrapper for DSL
  class DslRegistry
    attr_reader :task_list

    def initialize
      @task_list = []
    end

    def add_task(task)
      fail_non_task task unless task.is_a? Task
      fail_raw_task task unless task.class < Task
      @task_list.push task
    end

    private

    def fail_non_task(task)
      fail "Non-task given - #{task}"
    end

    def fail_raw_task(task)
      fail "Cannot use raw Task objects - #{task}"
    end
  end
end
