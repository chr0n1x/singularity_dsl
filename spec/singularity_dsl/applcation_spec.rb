# encoding: utf-8

require 'singularity_dsl/application'
require 'singularity_dsl/dsl'
require 'singularity_dsl/dsl_runner'
require 'singularity_dsl/errors'

describe 'Application' do
  let(:app) { SingularityDsl::Application.new }

  context '#initialize' do
    it 'creates base runner' do
      expect(app.runner).to be_kind_of SingularityDsl::DslRunner
    end

    it 'creates base dsl' do
      expect(app.dsl).to be_kind_of SingularityDsl::Dsl
    end
  end

  context '#load_script' do
    it 'just calls runner.load_ex_script' do
      stub_res = 'spooooooky ghooooost'
      app.runner.stub(:load_ex_script).and_return stub_res
      expect(app.load_script 'dummy').to eql stub_res
    end
  end

  context '#run' do
    it 'logs resource failures' do
      # don't want the entire thing to exit...
      app.stub(:post_task_runner_actions)
      app.runner.stub(:execute).and_raise(SingularityDsl::Errors::ResourceFail)
      expect(app).to receive(:log_resource_fail)
      app.run
    end

    it 'runner post-script actions are evaulated on failure' do
      app.stub(:post_task_runner_actions)
      app.stub(:log_resource_fail)
      app.runner.stub(:execute).and_raise(SingularityDsl::Errors::ResourceFail)
      expect(app).to receive(:post_task_runner_actions)
      app.run
    end

    it 'logs resource errors' do
      app.stub(:post_task_runner_actions)
      app.runner.stub(:execute).and_raise(SingularityDsl::Errors::ResourceError)
      expect(app).to receive(:log_resource_error)
      app.run
    end

    it 'runner post-script actions are evaulated on error' do
      app.stub(:post_task_runner_actions)
      app.stub(:log_resource_error)
      app.runner.stub(:execute).and_raise(SingularityDsl::Errors::ResourceError)
      expect(app).to receive(:post_task_runner_actions)
      app.run
    end
  end

  context '#post_task_runner_actions' do
    it 'actually calls runner.post_actions & exits' do
      app.runner.stub(:post_actions)
      expect(app.runner).to receive :post_actions
      expect { app.post_task_runner_actions }.to raise_error SystemExit
    end

    it 'outputs warning when script fails' do
      app.stub :script_warn
      app.runner.stub :post_actions
      app.stub :exit_run
      app.runner.state.stub(:failed).and_return true
      expect(app).to receive(:script_warn)
      app.post_task_runner_actions
    end

    it 'outputs warning when script errors' do
      app.stub :script_error
      app.runner.stub :post_actions
      app.stub :exit_run
      app.runner.state.stub(:error).and_return true
      expect(app).to receive(:script_error)
      app.post_task_runner_actions
    end
  end
end
