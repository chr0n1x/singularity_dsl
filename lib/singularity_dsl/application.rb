# encoding: utf-8

require 'singularity_dsl/dsl'
require 'singularity_dsl/dsl_runner'
require 'singularity_dsl/errors'
require 'rainbow'

module SingularityDsl
  # application singleton - environment container for script
  class Application
    include SingularityDsl::Errors

    def initialize
      @runner = DslRunner.new
      @dsl = Dsl.new
    end

    def load_script(script)
      @runner.load_ex_script script
    end

    def load_tasks(path)
    end

    def run(pass_errors = false)
      @runner.dsl @dsl
      begin
        @runner.execute pass_errors
      # resource failed, :all_tasks not specified
      rescue ResourceFail
        puts Rainbow('Script run failed!').yellow
      # resource actually failed & threw error
      rescue ResourceError
        puts Rainbow('Script run error!').red
      ensure
        puts Rainbow(@runner.state.failures).yellow if @runner.state.failed
        puts Rainbow(@runner.state.errors).red if @runner.state.error
        @runner.post_actions
      end
    end
  end
end
