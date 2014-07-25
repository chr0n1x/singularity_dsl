# encoding: utf-8

require 'rainbow'

module SingularityDsl
  # mixin for output wrappers
  module Stdout
    def info(message)
      puts Rainbow(message).cyan
    end

    def data(message)
      puts Rainbow(message).green
    end
  end
end
