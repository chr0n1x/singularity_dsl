# encoding: utf-8

require 'rainbow'
require 'terminal-table'

module SingularityDsl
  # CLI
  module Cli
    # util CLI table formatting fxs
    module Table
      private

      def task_row(dsl, task_class)
        name = dsl.task_name task_class
        task_name = dsl.task task_class
        desc = task_class.new.description
        [name, task_name, desc]
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
