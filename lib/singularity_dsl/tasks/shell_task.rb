# encoding: utf-8

require 'mixlib/shellout'
require 'singularity_dsl/stdout'
require 'singularity_dsl/task'

# shell-out resource for any ol commands
class ShellTask < SingularityDsl::Task
  include SingularityDsl::Stdout

  attr_reader :shell, :conditionals, :alternative, :no_fail
  attr_writer :live_stream

  def initialize(&block)
    @live_stream = STDOUT
    @conditionals = []
    @no_fail = false
    @alternative = 'echo "no alternative shell cmd defined"'
    super(&block)
  end

  def condition(cmd)
    invalid_cmd 'condition' unless cmd.is_a? String
    @conditionals.push cmd
  end

  def no_fail(switch)
    fail 'no_fail must be bool' unless bool? switch
    @no_fail = switch
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
    @live_stream << log_shell if @live_stream
    @shell.run_command
    return 0 if @no_fail
    @shell.exitstatus
  end

  def description
    'Runs a SH command using Mixlib::ShellOut'
  end

  def failed_status(status)
    ![0, false].include? status
  end

  private

  def log_shell(pre = '', shell = false)
    shell ||= @shell
    pre ||= ''
    log = "[ShellTask]:#{pre}:#{shell.command}"
    data(log)
  end

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
      log_shell '[conditional]', shell
      shell.run_command
      !failed_status(shell.exitstatus)
    end
  end
end
