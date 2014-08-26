# encoding: utf-8

require 'singularity_dsl/git_helper'

describe 'GitHelper' do
  before :each do
    allow_any_instance_of(SingularityDsl::GitHelper)
    .to receive(:git_installed)
    .and_return true
  end
  let(:git) { SingularityDsl::GitHelper.new }

  context '#initialize' do
    it 'sets verbose off' do
      expect(git.verbose).to eql false
    end

    it 'throws if git is not installed' do
      allow_any_instance_of(SingularityDsl::GitHelper)
        .to receive(:git_installed)
        .and_return false
      expect { SingularityDsl::GitHelper.new }
        .to(raise_error ArgumentError, /git not installed/)
    end
  end

  context '#verbose' do
    it 'sets verbose to true when number > 0 given' do
      git.verbosity 1
      expect(git.verbose).to eql true
    end

    it 'sets verbose to false when number == 0 given' do
      git.verbosity 0
      expect(git.verbose).to eql false
    end

    it 'sets verbose to false when non-Fixnum given' do
      git.verbosity 'wat'
      expect(git.verbose).to eql false
    end
  end

  context '#clean_reset' do
    it 'fails when reset fails' do
      allow(git).to receive(:reset).and_return(1)
      allow(git).to receive(:clean).and_return(0)
      expect { git.clean_reset }
        .to(raise_error RuntimeError, /failed to clean/)
    end

    it 'fails when clean fails' do
      allow(git).to receive(:reset).and_return(0)
      allow(git).to receive(:clean).and_return(1)
      expect { git.clean_reset }
        .to(raise_error RuntimeError, /failed to clean/)
    end

    it 'fails when both reset & clean fail' do
      allow(git).to receive(:reset).and_return(1)
      allow(git).to receive(:clean).and_return(1)
      expect { git.clean_reset }
        .to(raise_error RuntimeError, /failed to clean/)
    end
  end

  context '#merge_remote' do
    it 'generates & calls correct cmd' do
      allow(git).to receive(:remotes).and_return([])
      allow(git).to receive(:exec)
      .with('git fetch --all')
      allow(git).to receive(:exec)
      .with('git merge bar/foo').and_return(0)
      git.merge_remote 'foo', 'bar'
    end
  end

  context '#diff_remote' do
    it 'generates & calls correct cmd w/ single flag' do
      allow(git).to receive(:remotes).and_return([])
      allow(git).to receive(:exec)
      .with('git fetch --all')
      allow(git).to receive(:exec)
      .with('git diff bar/foo --flag').and_return(0)
      git.diff_remote 'foo', 'bar', '--flag'
    end

    it 'generates & calls correct cmd w/ multiple flags' do
      allow(git).to receive(:remotes).and_return([])
      allow(git).to receive(:exec)
      .with('git fetch --all')
      allow(git).to receive(:exec)
      .with('git diff bar/foo --flag --other').and_return(0)
      git.diff_remote 'foo', 'bar', %w(--flag, --other)
    end
  end
end
