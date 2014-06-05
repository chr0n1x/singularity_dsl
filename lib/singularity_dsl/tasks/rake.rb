# encoding: utf-8

require 'rake'
require 'pp'

module SingularityDsl
  # Rake resource
  class Rake < Task
    DESCRIPTION = 'Simple resource to just wrap the Rake CLI'

    attr_accessor :target

    def initialize(&block)
      super(&block)
    end

    def target(target)
      @target = target
    end

    def execute
      throw 'target is required' if @target.nil?
      ::Rake.application.init
      ::Rake.application.load_rakefile
      ::Rake.application[@target].invoke
    end
  end
end
