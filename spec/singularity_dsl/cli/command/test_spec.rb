# encoding: utf-8

require 'singularity_dsl/cli/command/test'

describe SingularityDsl::Cli::Command::Test do
  describe '#batch' do
    context ':batch given in options' do
      let(:cmd) { SingularityDsl::Cli::Command::Test.new(batch: 'foo') }

      it 'returns the given value' do
        expect(cmd.batch).to eql 'foo'
      end
    end

    context ':batch not given' do
      let(:cmd) { SingularityDsl::Cli::Command::Test.new }

      it 'returns the given value' do
        expect(cmd.batch).to eql false
      end
    end
  end
end
