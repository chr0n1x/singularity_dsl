# encoding: utf-8

require 'singularity_dsl/cli/command/command'
require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/stdout'

require 'rainbow'
require 'terminal-table'

module SingularityDsl
  module Cli
    module Command
      # tasks command
      # Prints out known tasks in the given task path
      class Tasks < Command
        include SingularityDsl::Stdout

        def execute
          dsl = SingularityDsl::Dsl::Dsl.new
          dsl.load_tasks_in_path tasks_path if tasks_path
          table = task_table
          dsl.task_list.each do |task|
            task_rows(dsl, task).each { |row| table.add_row row }
          end
          data table
        end

        private

        def task_table
          headers = [
            Rainbow('Task').yellow,
            Rainbow('Task Function').yellow,
            Rainbow('Description').yellow
          ]
          table = ::Terminal::Table.new headings: headers
          table.style = { border_x: '', border_y: '', border_i: '' }
          table
        end

        def desc_rows(desc)
          desc_lines = []
          line = ''
          desc.split(' ').each do |word|
            if (line + word).length > 80
              desc_lines.push line.strip
              line = ''
            end
            line += " #{word}"
          end
          desc_lines.push line.strip
          desc_lines
        end

        def task_rows(dsl, task_class)
          desc_lines = desc_rows task_class.new.description
          name = dsl.task_name task_class
          task_name = dsl.task task_class
          rows = [[name, task_name, desc_lines.shift]]
          desc_lines.each { |line| rows.push ['', '', line] }
          rows
        end
      end
    end
  end
end
