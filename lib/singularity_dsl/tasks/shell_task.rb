# encoding: utf-8

require 'mixlib/shellout'

module SingularityDsl
  # shell-out resource for any ol commands
  class ShellTask < Task
    attr_reader :shell

    def initialize
      super
    end

    def command(cmd)
      @shell = Mixlib::ShellOut.new cmd
    end

    def execute
      throw 'command never defined' if @shell.nil?
      @shell.run_command
      @shell.exitstatus
    end
  end
end
