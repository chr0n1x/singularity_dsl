# encoding: utf-8

# YEAH, THAT'S RIGHT
if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  throw 'Sorry, wont run on mswin|mingw32|windows'
end

# SingularityDsl Module
# logic for task -> file mapping
# ==== WARNING: HERE THERE BE DRAGONS ====
module SingularityDsl
  class << self
    attr_reader :task_map
  end

  @task_map = {}

  def self.map_task_file(obj, file)
    @task_map[map_key obj] = file
  end

  def self.task_file(obj)
    return false unless @task_map.key? map_key(obj)
    @task_map[map_key obj]
  end

  def self.reset_map
    @task_map = {}
  end

  def self.map_key(obj)
    obj = obj.class unless obj.class.eql? Class
    obj.to_s.to_sym
  end
end

require 'singularity_dsl/application'
require 'singularity_dsl/dsl/components'
