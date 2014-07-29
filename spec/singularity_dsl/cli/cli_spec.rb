# encoding: utf-8

require 'singularity_dsl/cli/cli'

describe 'Cli' do
  let(:cli) { SingularityDsl::Cli::Cli.new }

  context '#testmerge' do
    before(:each) do
      expect(cli).to receive(:test_merge)
      expect(cli).to receive(:diff_list)
      expect(cli).to receive(:remove_remotes)
    end

    it 'runs test method if no run_task' do
      cli.stub(:target_run_task).and_return false
      expect(cli).to receive(:test)
      cli.testmerge 'fork', 'fork_branch', 'base_branch'
    end

    it 'runs batch method if no run_task' do
      cli.stub(:target_run_task).and_return 'test_batch'
      expect(cli).to receive(:batch)
      cli.testmerge 'fork', 'fork_branch', 'base_branch'
    end
  end
end
