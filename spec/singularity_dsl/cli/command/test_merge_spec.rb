# encoding: utf-8

require 'singularity_dsl/cli/command/test_merge'

describe SingularityDsl::Cli::Command::TestMerge do
  def create_command(params = {})
    SingularityDsl::Cli::Command::TestMerge.new params
  end

  def cmd_double(expected = false)
    mock = double.as_null_object
    allow(mock).to receive(:exitstatus).and_return 0
    allow(mock).to receive(:stdout).and_return expected if expected
    mock
  end

  def expect_git_cmd(cmd, expected = false)
    mock = cmd_double(expected)
    expect(::Mixlib::ShellOut)
      .to receive(:new).with(cmd)
      .once
      .and_return(mock)
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
        expect(cmd.bootstrap_cwd(repo)).to eql cmd
      end
    end

    context ':bootstrap_cwd is true' do
      let(:cmd) { create_command(bootstrap_cwd: true) }

      context 'and the cwd is an empty directory' do
        before :each do
          allow(::File).to receive(:exist?).and_return(false)
        end

        it 'attempts clone into local directory' do
          allow(cmd.git).to receive :verbosity
          expect_git_cmd("git clone #{repo} .")
          expect_git_cmd('git submodule update --init --recursive')
          expect(cmd.bootstrap_cwd(repo)).to eql cmd
        end
      end

      context 'and the cwd is a git directory' do
        before :each do
          allow(::File).to receive(:exist?).and_return(true)
        end

        it 'attempts to clean & reset local' do
          allow(cmd.git).to receive :verbosity
          expect_git_cmd('git clean -ffdx')
          expect_git_cmd('git add . && git reset --hard')
          expect_git_cmd('git submodule update --init --recursive')
          expect(cmd.bootstrap_cwd(repo)).to eql cmd
        end
      end
    end
  end

  describe '#set_fork_env' do
    let(:cmd) { create_command }
    let(:repo) { 'fakedood/fakerepo' }
    let(:branch) { 'fakedoodbranch' }

    it 'sets ENV vars correctly' do
      gitid = 'gitid'
      author = 'fakedood'
      author_email = 'fakedood@usa.lan'
      committer = 'fakedoodbro'
      committer_email = 'fakedoodbro@fakedoodsbutt.lan'
      message = 'bro I commit some things tight tight tight'

      expect_git_cmd("git remote add fakedood_fakerepo #{repo}")
      expect_git_cmd('git fetch --all')
      expect_git_cmd("git checkout fakedood_fakerepo/#{branch}")
      expect_git_cmd('git remote rm fakedood_fakerepo')
      expect_git_cmd("git log -1 --pretty=format:'%H'", gitid)
      expect_git_cmd("git log -1 --pretty=format:'%aN'", author)
      expect_git_cmd("git log -1 --pretty=format:'%ae'", author_email)
      expect_git_cmd("git log -1 --pretty=format:'%cN'", committer)
      expect_git_cmd("git log -1 --pretty=format:'%ce'", committer_email)
      expect_git_cmd("git log -1 --pretty=format:'%s'", message)

      expect(ENV).to receive(:[]=).with('GIT_ID', gitid)
      expect(ENV).to receive(:[]=).with('GIT_AUTHOR_NAME', author)
      expect(ENV).to receive(:[]=).with('GIT_AUTHOR_EMAIL', author_email)
      expect(ENV).to receive(:[]=).with('GIT_COMMITTER_NAME', committer)
      expect(ENV).to receive(:[]=).with('GIT_COMMITTER_EMAIL', committer_email)
      expect(ENV).to receive(:[]=).with('GIT_MESSAGE', message)
      expect(ENV).to receive(:[]=).with('GIT_BRANCH', branch)

      cmd.set_fork_env(repo, branch)
    end
  end
end
