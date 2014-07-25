# encoding: utf-8

require 'mixlib/shellout'

# shell-out resource for any ol commands
class ShellTask < SingularityDsl::Task
  attr_reader :shell, :conditionals, :alternative
  attr_writer :live_stream

  def initialize(&block)
    @live_stream = STDOUT
    @conditionals = []
    @alternative = 'echo "no alternative shell cmd defined"'
    super(&block)
  end

  def condition(cmd)
    invalid_cmd 'condition' unless cmd.is_a? String
    @conditionals.push cmd
  end

  def alt(cmd)
    invalid_cmd 'alt' unless cmd.is_a? String
    @alternative = cmd
  end

  def command(cmd)
    @task_name = cmd
    @shell = setup_shell cmd
  end

  def task_name
    return @task_name if @task_name
    super
  end

  def execute
    throw 'command never defined' if @shell.nil?
    command @alternative unless evaluate_conditionals
    @shell.run_command
    @shell.exitstatus
  end

  def description
    'Runs a SH command using Mixlib::ShellOut'
  end

  private

  def setup_shell(cmd)
    shell = ::Mixlib::ShellOut.new cmd
    shell.live_stream = @live_stream if @live_stream
    shell
  end

  def invalid_cmd(type)
    throw "#{type} must be string"
  end

  def evaluate_conditionals
    @conditionals.all? do |cmd|
      shell = setup_shell cmd
      shell.run_command
      !failed_status(shell.exitstatus)
    end
  end
end
