# encoding: utf-8

require 'singularity_dsl/cli'
require 'singularity_dsl/cli/command'

describe 'Cli' do
  let(:cli) { SingularityDsl::Cli::Cli.new }

  before :each do
    @cmd_double = double
    allow(@cmd_double).to receive :execute
  end

  describe '#batch' do
    it 'injects batch name directly into options' do
      expect(SingularityDsl::Cli::Command::Test).to receive(:new)
        .with(hash_including('batch' => 'foo'))
        .and_return(@cmd_double)

      cli.batch 'foo'
    end
  end
end
