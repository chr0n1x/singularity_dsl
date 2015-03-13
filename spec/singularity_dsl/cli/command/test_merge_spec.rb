# encoding: utf-8

require 'singularity_dsl/cli/command/test_merge'

describe SingularityDsl::Cli::Command::TestMerge do
  def create_command(params)
    SingularityDsl::Cli::Command::TestMerge.new params
  end

  describe '#batch' do
    context ':run_task given' do
      let(:cmd) { create_command(run_task: 'foo') }

      it 'returns batch' do
        expect(cmd.batch).to eql 'foo'
      end
    end

    context ':run_task not given' do
      let(:cmd) { create_command(run_task: '') }

      it 'returns false when :run_task is an empty string' do
        expect(cmd.batch).to eql false
      end
    end
  end

  describe '#bootstrap_cwd' do
    let(:repo) { 'fakedood/fakerepo' }

    context ':bootstrap_cwd is false' do
      let(:cmd) { create_command(bootstrap_cwd: false) }

      it 'does nothing' do
        allow(cmd.git).to receive :verbosity
        expect(cmd.bootstrap_cwd repo).to eql cmd
      end
    end

    context ':bootstrap_cwd is true' do
      def expect_git_cmd(cmd)
        cmd_double = double.as_null_object
        allow(cmd_double).to receive(:exitstatus).and_return 0
        expect(::Mixlib::ShellOut)
          .to receive(:new).with(cmd)
          .once
          .and_return(cmd_double)
      end

      let(:cmd) { create_command(bootstrap_cwd: true) }

      context 'and the cwd is an empty directory' do
        before :each do
          allow(::File).to receive(:exist?).and_return(false)
        end

        it 'attempts clone into local directory' do
          allow(cmd.git).to receive :verbosity
          expect_git_cmd("git clone #{repo} .")
          expect_git_cmd('git submodule update --init --recursive')
          expect(cmd.bootstrap_cwd repo).to eql cmd
        end
      end

      context 'and the cwd is a git directory' do
        before :each do
          allow(::File).to receive(:exist?).and_return(true)
        end

        it 'attempts to clean & reset local' do
          allow(cmd.git).to receive :verbosity
          expect_git_cmd('git clean -fdx')
          expect_git_cmd('git add . && git reset --hard')
          expect_git_cmd('git submodule update --init --recursive')
          expect(cmd.bootstrap_cwd repo).to eql cmd
        end
      end
    end
  end
end
