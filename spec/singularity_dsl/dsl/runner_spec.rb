# encoding: utf-8

require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/dsl/runner'
require 'singularity_dsl/runstate'
require 'singularity_dsl/task'

describe 'DslRunner' do
  let!(:dsl) { SingularityDsl::Dsl::Dsl.new }
  let!(:registry) { double('registry double') }
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

  context '#post_actions' do
    let(:always_proc) { ::Proc.new { always_method } }
    let(:error_proc) { ::Proc.new { error_method } }
    let(:fail_proc) { ::Proc.new { fail_method } }
    let(:success_proc) { ::Proc.new { success_method } }

    before :each do
      allow(SingularityDsl::Dsl::Dsl).to receive(:new).and_return(dsl)
      allow(dsl).to receive(:always_procs).and_return([always_proc])

      # to halt #execute
      allow(dsl).to receive(:load_ex_proc).and_call_original
      allow(registry).to receive(:run_list).and_return([])
    end

    it 'triggers error procs when there is an error' do
      allow(runner.state).to receive(:error).and_return true
      allow(dsl).to receive(:error_procs).and_return([error_proc])

      expect(dsl).to receive(:always_method)
      expect(dsl).to receive(:error_method)

      # once for the error proc, other for always
      expect(runner).to receive(:execute).with(dsl).twice

      runner.post_actions dsl
    end

    it 'triggers fail procs when there is a failure' do
      allow(runner.state).to receive(:failed).and_return true
      allow(dsl).to receive(:fail_procs).and_return([fail_proc])

      expect(dsl).to receive(:always_method)
      expect(dsl).to receive(:fail_method)

      # once for the fail proc, other for always
      expect(runner).to receive(:execute).with(dsl).twice

      runner.post_actions dsl
    end

    it 'triggers success procs when no failure nor error' do
      allow(runner.state).to receive(:failed).and_return false
      allow(runner.state).to receive(:error).and_return false
      allow(dsl).to receive(:success_procs).and_return([success_proc])

      expect(dsl).to receive(:always_method)
      expect(dsl).to receive(:success_method)

      # once for the success proc, other for always
      expect(runner).to receive(:execute).with(dsl).twice

      runner.post_actions dsl
    end
  end
end
