# encoding: utf-8

require 'mixlib/shellout'

# shell-out resource for any ol commands
class ShellTask < SingularityDsl::Task
  attr_reader :shell

  def initialize
    super
  end

  def command(cmd)
    @shell = Mixlib::ShellOut.new cmd
    @shell.live_stream = STDOUT
  end

  def execute
    throw 'command never defined' if @shell.nil?
    @shell.run_command
    @shell.exitstatus
  end
end
