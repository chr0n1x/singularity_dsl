# encoding: utf-8

require 'singularity_dsl/cli/command/app_runner_command'

describe SingularityDsl::Cli::Command::AppRunnerCommand do
  let(:cmd) { SingularityDsl::Cli::Command::AppRunnerCommand.new }

  describe '#initialize_app' do
    context 'no script given' do
      it 'fails' do
        expect { cmd.initialize_app }.to raise_error(/Invalid script/)
      end
    end

    context 'a script is given' do
      let(:script) { 'path/to/a/singularity/script' }
      let(:cfg) { { script: script } }
      let(:cmd) do
        SingularityDsl::Cli::Command::AppRunnerCommand.new cfg
      end

      context 'and it is an invalid path' do
        before :each do
          allow(::File).to receive(:exist?).with(script).and_return false
        end

        it 'fails' do
          expect { cmd.initialize_app }.to raise_error(/Invalid script/)
        end
      end
    end
  end
end
