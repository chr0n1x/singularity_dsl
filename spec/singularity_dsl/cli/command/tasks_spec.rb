# encoding: utf-8

require 'singularity_dsl/cli/command/tasks'

describe SingularityDsl::Cli::Command::Tasks do
  describe '#execute' do
    let(:cmd) { SingularityDsl::Cli::Command::Tasks.new }

    it 'prints out a table of built-in tasks' do
      # this is...kind of hard to test
      expect(cmd).to receive(:data)
      cmd.execute
    end
  end
end
