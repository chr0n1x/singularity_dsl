# encoding: utf-8

require 'rainbow'

module SingularityDsl
  # mixin for output wrappers
  module Stdout
    def list_items(items)
      items = [*items]
      items.each { |item| puts Rainbow(item).magenta }
    end

    def info(message)
      puts Rainbow(message).cyan
    end

    def data(message)
      puts Rainbow(message).green
    end
  end
end
