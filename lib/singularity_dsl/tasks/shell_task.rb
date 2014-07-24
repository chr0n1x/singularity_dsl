# encoding: utf-8

require 'mixlib/shellout'

# shell-out resource for any ol commands
class ShellTask < SingularityDsl::Task
  attr_reader :shell

  def task_name
    return @task_name if @task_name
    super
  end

  def command(cmd)
    @task_name = cmd
    @shell = Mixlib::ShellOut.new cmd
    @shell.live_stream = STDOUT
  end

  def execute
    throw 'command never defined' if @shell.nil?
    @shell.run_command
    @shell.exitstatus
  end

  def description
    'Runs a SH command using Mixlib::ShellOut'
  end
end
