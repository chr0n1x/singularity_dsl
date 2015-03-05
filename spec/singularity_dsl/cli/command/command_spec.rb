# encoding: utf-8

require 'singularity_dsl/cli/command/command'

describe SingularityDsl::Cli::Command::Command do
  let(:cmd) { SingularityDsl::Cli::Command::Command.new }

  describe '#initialize' do
    it 'sets default options to {}' do
      expect(cmd.options).to eql({})
    end
  end

  describe '#execute' do
    it 'fails' do
      expect { cmd.execute }.to raise_error(/cannot execute/)
    end
  end

  describe '#tasks_path' do
    context 'no path given in options' do
      it 'returns false' do
        expect(cmd.tasks_path).to eql false
      end
    end

    context 'path given in options' do
      let(:file) { 'some/file/dir/path/thing/given' }
      let(:cmd) { SingularityDsl::Cli::Command::Command.new task_path: file }

      context 'and path exists' do
        let(:expanded_file) { '/expanded/some/file/dir/path/thing/given' }
        before :each do
          allow(::File).to receive(:exist?)
            .with(file).and_return true
          allow(::File).to receive(:expand_path)
            .with(file).and_return expanded_file
        end

        it 'returns expanded path' do
          expect(cmd.tasks_path).to eql expanded_file
        end
      end

      context 'and path does not exist' do
        before :each do
          allow(::File).to receive(:exist?)
            .with(file).and_return false
        end

        it 'returns expanded path' do
          expect(cmd.tasks_path).to eql false
        end
      end
    end
  end
end
