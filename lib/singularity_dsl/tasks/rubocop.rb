# encoding: utf-8

require 'rubocop'

module SingularityDsl
  # Rake resource
  class Rubocop < Task
    DESCRIPTION = 'Runs rubocop, loads .rubocop.yml from ./'
    DEFAULT_CONFIG = './.rubocop.yml'

    attr_accessor :violation_found, :files, :cfg_file, :cfg_store

    def initialize(&block)
      @violation_found = false
      @files = []
      @cfg_files = [DEFAULT_CONFIG]
      @cfg_store = ::RuboCop::ConfigStore.new
      super(&block)
    end

    def config_file(file)
      validate_file file

      return if @cfg_files.include? file
      warn 'Loading multiple configs' if File.exist? DEFAULT_CONFIG

      @cfg_files.push file
      @cfg_store.options_config = file
    end

    def file(file)
      validate_file file
      @files.push file
    end

    def execute
      inspector = ::RuboCop::FileInspector.new({})
      @violation_found = inspector.process_files files, @cfg_store do
        false
      end
    end

    private

    def files
      ::RuboCop::TargetFinder.new(@cfg_store).find @files
    end
  end
end
