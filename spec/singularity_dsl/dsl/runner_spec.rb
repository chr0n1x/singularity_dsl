# encoding: utf-8

require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/dsl/runner'
require 'singularity_dsl/runstate'
require 'singularity_dsl/task'

describe 'DslRunner' do
  let!(:dsl) { SingularityDsl::Dsl::Dsl.new }
  let!(:registry) { SingularityDsl::Dsl::Registry.new }
  let(:runner) { SingularityDsl::Dsl::Runner.new }

  before :each do
    allow(dsl).to receive(:registry).and_return(registry)
  end

  context '#initialize' do
    it 'creates base state' do
      expect(runner.state).to be_kind_of SingularityDsl::Runstate
    end
  end

  context '#execute' do
    it 'taps & evaluates failed task.execute statuses correctly' do
      task = SingularityDsl::Task.new
      allow(task).to receive(:execute).and_return(true)
      allow(dsl.registry).to receive(:run_list).and_return([task])
      expect(runner).to receive(:record_failure).with task
      expect(runner).to receive(:resource_fail).with task
      runner.execute dsl
    end
  end
end
