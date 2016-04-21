# encoding: utf-8

module SingularityDsl
  # Task abstraction class
  class Task
    def initialize(&block)
      instance_eval(&block) unless block.nil?
    end

    def validate_file(file)
      throw "Cannot find #{file}" unless ::File.exist? file
    end

    def execute
      raise 'SingularityDsl::Task::execute not implemented'
    end

    def failed_status(status)
      ![nil, 0, false].include? status
    end

    def description
      "Runs #{self.class} task"
    end

    def task_name
      false
    end

    def bool?(val)
      val.is_a?(TrueClass) || val.is_a?(FalseClass)
    end
  end
end
