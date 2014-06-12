# encoding: utf-8

module SingularityDsl
  # Task abstraction class
  class Task
    def initialize(&block)
      instance_eval(&block) unless block.nil?
    end

    def validate_file(file)
      throw "Cannot find #{file}" unless File.exist? file
    end

    def execute
      fail 'SingularityDsl::Task::execute not implemented'
    end

    def failed_status(status)
      ![nil, 0, false].include? status
    end

    def description
      "Runs #{self.class} task"
    end
  end
end
