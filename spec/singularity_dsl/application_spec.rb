# encoding: utf-8

require 'singularity_dsl/application'

describe 'Application' do
  let(:app) { SingularityDsl::Application.new }

  context '#initialize' do
    it 'creates base runner' do
      expect(app.runner).to be_kind_of SingularityDsl::Dsl::Runner
    end
  end

  context '#load_script' do
    it 'just calls runner.load_ex_script' do
      stub_res = 'spooooooky ghooooost'
      allow(app.runner).to(receive(:load_ex_script).and_return stub_res)
      expect(app.load_script 'dummy').to eql stub_res
    end
  end

  context '#run' do
    it 'logs resource failures' do
      # don't want the entire thing to exit...
      allow(app).to receive(:post_task_runner_actions)
      allow(app.runner).to receive(:execute)
        .and_raise(SingularityDsl::Errors::ResourceFail)
      expect(app).to receive(:log_resource_fail)
      app.run
    end

    it 'runner post-script actions are evaulated on failure' do
      allow(app).to receive(:post_task_runner_actions)
      allow(app).to receive(:log_resource_fail)
      allow(app.runner).to receive(:execute)
        .and_raise(SingularityDsl::Errors::ResourceFail)
      expect(app).to receive(:post_task_runner_actions)
      app.run
    end

    it 'logs resource errors' do
      allow(app).to receive(:post_task_runner_actions)
      allow(app.runner).to receive(:execute)
        .and_raise(SingularityDsl::Errors::ResourceError)
      expect(app).to receive(:log_resource_error)
      app.run
    end

    it 'runner post-script actions are evaulated on error' do
      allow(app).to receive(:post_task_runner_actions)
      allow(app).to receive(:log_resource_error)
      allow(app.runner).to receive(:execute)
        .and_raise(SingularityDsl::Errors::ResourceError)
      expect(app).to receive(:post_task_runner_actions)
      app.run
    end

    it 'runner post-script actions are evaulated on error' do
      allow(app).to receive(:post_task_runner_actions)
      allow(app).to receive(:execute)
      expect(app.runner.state).to receive :exit_code
      app.run
    end
  end

  context '#post_task_runner_actions' do
    it 'outputs warning when script fails' do
      allow(app).to receive(:script_warn)
      allow(app.runner).to receive(:post_actions)
      allow(app).to receive(:exit_run)
      allow(app.runner.state).to receive(:failed).and_return(true)
      expect(app).to receive(:script_warn)
      app.post_task_runner_actions
    end

    it 'outputs warning when script errors' do
      allow(app).to receive(:script_error)
      allow(app.runner).to receive(:post_actions)
      allow(app).to receive(:exit_run)
      allow(app.runner.state).to receive(:error).and_return(true)
      expect(app).to receive(:script_error)
      app.post_task_runner_actions
    end
  end

  context '#change_list' do
    it 'returns a sorted list' do
      expect(app.change_list(%w(b c e a d)))
        .to eql %w(a b c d e)
    end

    it 'handles empty lists' do
      expect(app.change_list([])).to eql []
    end
  end
end
