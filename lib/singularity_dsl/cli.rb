# encoding: utf-8

require 'highline'
require 'rainbow'
require 'singularity_dsl'
require 'terminal-table'
require 'thor'

# required for DSL in .singularity.rb to just work
include SingularityDsl

module SingularityDsl
  # CLI Thor task
  class Cli < Thor
    include SingularityDsl::Errors

    # TEST COMMAND
    option :all_tasks,
           aliases: '-a',
           type: :boolean,
           desc: 'Do not stop on task failure(s), continuously collect results'
    option :script,
           aliases: '-s',
           type: :string,
           desc: 'Specify path to a .singularity.rb file',
           default: './.singularity.rb'
    desc 'test', 'Run singularity script.'
    def test
      SingularityDsl.load_tasks
      say Rainbow("Loading CI script from #{singularity_script} ...").blue
      # only way to halt execution of the loaded script
      # ...that I know of :(
      begin
        load singularity_script
        SingularityDsl::Application.instance.execute options[:all_tasks]
      # resource failed, :all_tasks not specified
      rescue ResourceFail
        say Rainbow('Script run failed!').yellow
      # resource actually failed & threw error
      rescue ResourceError
        puts Rainbow('Script run error!').red
      ensure
        state = SingularityDsl::Application.instance.state
        say Rainbow(state.failures).yellow if state.failed
        say Rainbow(state.errors).red if state.error
        SingularityDsl::Application.instance.post_actions
      end
    end

    # TASKS COMMAND
    desc 'tasks', 'Available tasks.'
    def tasks
      table = task_table
      SingularityDsl.task_list.each do |task|
        name = task_name task
        desc = task.description
        table.add_row [name, desc]
      end
      say table
    end

    private

    def task_table
      headers = [Rainbow('Task').yellow, Rainbow('Description').yellow]
      table = Terminal::Table.new headings: headers
      table.style = { border_x: '', border_y: '', border_i: '' }
      table
    end

    def singularity_script
      File.expand_path options[:script]
    end
  end
end
