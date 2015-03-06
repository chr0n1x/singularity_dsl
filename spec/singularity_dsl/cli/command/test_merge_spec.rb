# encoding: utf-8

require 'singularity_dsl/cli/command/test_merge'

describe SingularityDsl::Cli::Command::TestMerge do
  describe '#batch' do
    context ':run_task given' do
      let(:cmd) { SingularityDsl::Cli::Command::TestMerge.new(run_task: 'foo') }

      it 'returns batch' do
        expect(cmd.batch).to eql 'foo'
      end
    end

    context ':run_task not given' do
      let(:cmd) { SingularityDsl::Cli::Command::TestMerge.new(run_task: '') }

      it 'returns false when :run_task is an empty string' do
        expect(cmd.batch).to eql false
      end
    end
  end
end
