# encoding: utf-8

require 'rake'

# Rake Task
class Rake < Task
  attr_accessor :target, :rake

  def initialize(&block)
    ::Rake.application.init
    @rake = ::Rake.application
    super(&block)
  end

  def target(target)
    @target = target
    @target.strip!
  end

  def execute
    throw 'target is required' if @target.nil?
    @rake.load_rakefile
    ret = @rake[@target].invoke
    return ret.count if ret.kind_of? Array
    ret
  end

  def description
    'Simple resource to just wrap the Rake CLI'
  end
end
