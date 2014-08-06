# encoding: utf-8

require 'rainbow'
require 'terminal-table'

module SingularityDsl
  # CLI
  module Cli
    # util CLI table formatting fxs
    module Table
      private

      def task_rows(dsl, task_class)
        desc_lines = desc_rows task_class.new.description
        name = dsl.task_name task_class
        task_name = dsl.task task_class
        rows = [[name, task_name, desc_lines.shift]]
        desc_lines.each { |line| rows.push ['', '', line] }
        rows
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

      def task_table
        headers = [
          Rainbow('Task').yellow,
          Rainbow('Task Function').yellow,
          Rainbow('Description').yellow
        ]
        table = Terminal::Table.new headings: headers
        table.style = { border_x: '', border_y: '', border_i: '' }
        table
      end
    end
  end
end
