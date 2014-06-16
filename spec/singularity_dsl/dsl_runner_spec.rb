# encoding: utf-8

require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/dsl/runner'
require 'singularity_dsl/runstate'
require 'singularity_dsl/task'

describe 'DslRunner' do
  let(:runner) { SingularityDsl::Dsl::Runner.new }

  context '#initialize' do
    it 'creates base state' do
      expect(runner.state).to be_kind_of SingularityDsl::Runstate
    end

    it 'creates base DSL' do
      expect(runner.dsl).to be_kind_of SingularityDsl::Dsl::Dsl
    end
  end

  context '#execute' do
    it 'taps & evaluates failed task.execute statuses correctly' do
      task = SingularityDsl::Task.new
      task.stub(:execute).and_return true
      runner.dsl.registry.stub(:task_list).and_return [task]
      expect(runner).to receive(:record_failure).with task
      expect(runner).to receive(:resource_fail).with task
      runner.execute
    end
  end

  context '#load_ex_script' do
    it 'instance_evals contents of a file' do
      ::File.stub(:read).and_return('0')
      expect(runner.dsl).to receive(:instance_eval).with('0')
      runner.load_ex_script 'foo'
    end
  end
end
