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
    option :task_dir,
           aliases: '-t',
           type: :string,
           desc: 'Directory where custom tasks are defined',
           default: './.singularity'
    desc 'test', 'Run singularity script.'
    def test
      app = SingularityDsl::Application.new
      info "Loading CI script from #{singularity_script} ..."
      if File.exist? tasks_path
        info "Loading tasks from #{tasks_path}"
        app.load_tasks tasks_path
      end
      app.load_script singularity_script
      app.run
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

    def info(message)
      say Rainbow(message).blue
    end

    def task_table
      headers = [Rainbow('Task').yellow, Rainbow('Description').yellow]
      table = Terminal::Table.new headings: headers
      table.style = { border_x: '', border_y: '', border_i: '' }
      table
    end

    def singularity_script
      File.expand_path options[:script]
    end

    def tasks_path
      File.expand_path options[:task_dir]
    end
  end
end
