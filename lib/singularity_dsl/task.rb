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
      throw 'SingularityDsl::Task::execute not implemented'
    end

    def self.description
      desc = const_get 'DESCRIPTION' if constants.include? :DESCRIPTION
      desc ||= "Runs #{self} task"
      desc
    end
  end
end
