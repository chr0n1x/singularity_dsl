# encoding: utf-8

require 'singleton'
require 'singularity_dsl/errors'
require 'singularity_dsl/runstate'

module SingularityDsl
  # application singleton - environment & task container
  class Application
    include ::Singleton
    include SingularityDsl::Errors

    attr_reader :state

    def initialize
      @state = Runstate.new
      @tasks = []
    end

    def add_task(task)
      throw "#{task} is not a Task!" unless task.class < Task
      @tasks.push task
    end

    def execute(ignore_fails)
      @tasks.each do |task|
        failed = false

        begin
          failed = task.execute
        rescue StandardError => err
          @state.add_error "#{err.message}\n#{err.backtrace}"
          resource_err task
        end

        @state.add_failure klass_failed(task) if failed_status failed

        # used exclusivly to just halt .singularity.rb script execution
        resource_fail task if failed && !ignore_fails

        failed
      end
    end
  end
end
