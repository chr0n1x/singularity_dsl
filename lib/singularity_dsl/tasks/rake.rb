# encoding: utf-8

require 'rake'

# Rake Task
class Rake < Task
  @description = 'Simple resource to just wrap the Rake CLI'

  attr_accessor :target, :rake

  def initialize(&block)
    ::Rake.application.init
    ::Rake.application.load_rakefile
    @rake = ::Rake.application
    super(&block)
  end

  def target(target)
    @rake[target]
    @target = target
  end

  def execute
    throw 'target is required' if @target.nil?
    @rake[@target].invoke
  end
end
