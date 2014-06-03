# encoding: utf-8

require 'highline'
require 'rainbow'
require 'singularity_dsl'
require 'terminal-table'
require 'thor'

module SingularityDsl
  # CLI Thor task
  class Cli < Thor
    attr_reader :config_hash

    class_option :script,
                 aliases: '-s',
                 type: :string,
                 desc: 'Specify path to a .singularity.rb file',
                 default: './.singularity.rb'
    class_option :debug,
                 aliases: '-d',
                 type: :boolean,
                 desc: 'Turn on debug mode'

    desc 'test', 'Run singularity script.'
    def test
      task_list.each do |klass|
        define_method(task_to_sym klass) do |&block|
          Object.const_get(get_task_name klass).new(&block)
        end
      end
      load File.expand_path options[:script]
    end

    desc 'tasks', 'Available tasks.'
    def tasks
      headers = [Rainbow('Task').yellow, Rainbow('Description').yellow]
      table = Terminal::Table.new headings: headers
      table.style = { border_x: '', border_y: '', border_i: '' }
      SingularityDsl.task_list.each do |task|
        name = task_name task
        desc = task.description if task.method_defined? 'description'
        desc ||= "Run the #{name} task"
        table.add_row [name, desc]
      end
      say table
    end
  end
end

# required for DSL in .singularity.rb to just work
include SingularityDsl
