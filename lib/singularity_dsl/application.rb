# encoding: utf-8

require 'singularity_dsl/dsl_generator'
require 'singularity_dsl/dsl_runner'
require 'singularity_dsl/errors'
require 'rainbow'

module SingularityDsl
  # application singleton - environment container for script
  class Application
    include SingularityDsl::Errors

    def initialize
      @runner = DslRunner.new
      @generator = DslGenerator.new
    end

    def load_script(script)
      @runner.load_ex_script script
    end

    def load_tasks(path)
    end

    def run
      @runner.dsl @generator.dsl
      @runner.execute
    end

    private

    def dummy
      app.load_tasks
      app.load_execution singularity_script
      # only way to halt execution of the loaded script
      # ...that I know of :(
      begin
        app.execute options[:all_tasks]
      # resource failed, :all_tasks not specified
      rescue ResourceFail
        say Rainbow('Script run failed!').yellow
      # resource actually failed & threw error
      rescue ResourceError
        puts Rainbow('Script run error!').red
      ensure
        say Rainbow(app.state.failures).yellow if app.state.failed
        say Rainbow(app.state.errors).red if app.state.error
        app.post_actions
      end
    end
  end
end
