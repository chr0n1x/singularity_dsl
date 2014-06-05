# encoding: utf-8

require 'singularity_dsl/task'

module SingularityDsl
  # PHPUnit abstraction Task class
  class PHPUnit < Task
    def execute
      puts 'phpunit'
    end
  end
end
