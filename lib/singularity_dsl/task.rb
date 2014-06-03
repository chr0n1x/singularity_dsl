# encoding: utf-8

module SingularityDsl
  # Task abstraction class
  class Task
    attr_accessor :state, :exit_code

    def initialize(&block)
      instance_eval(&block)
    end

    def execute
      throw 'SingularityDsl::Task::execute must be implemented'
    end

    def set_state
      throw 'SingularityDsl::Task::set_state must be implemented'
    end
  end
end
