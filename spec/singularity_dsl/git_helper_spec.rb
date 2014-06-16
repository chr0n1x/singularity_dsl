# encoding: utf-8

require 'singularity_dsl/git_helper'

describe 'GitHelper' do
  before :each do
    SingularityDsl::GitHelper
      .any_instance
      .stub(:git_installed)
      .and_return true
  end
  let(:git) { SingularityDsl::GitHelper.new }

  context '#initialize' do
    it 'throws if git is not installed' do
      SingularityDsl::GitHelper
        .any_instance
        .stub(:git_installed)
        .and_return false
      expect { SingularityDsl::GitHelper.new }
        .to(raise_error ArgumentError, /git not installed/)
    end
  end

  context '#clean_reset' do
    it 'fails when reset fails' do
      git.stub(:reset).and_return 1
      git.stub(:clean).and_return 0
      expect { git.clean_reset }
        .to(raise_error RuntimeError, /failed to clean/)
    end

    it 'fails when clean fails' do
      git.stub(:reset).and_return 0
      git.stub(:clean).and_return 1
      expect { git.clean_reset }
        .to(raise_error RuntimeError, /failed to clean/)
    end

    it 'fails when both reset & clean fail' do
      git.stub(:reset).and_return 1
      git.stub(:clean).and_return 1
      expect { git.clean_reset }
        .to(raise_error RuntimeError, /failed to clean/)
    end
  end

  context '#merge_remote' do
    it 'generates & calls correct cmd' do
      git.stub(:remotes).and_return []
      git.stub(:exec).with('git fetch --all')
      git.stub(:exec).with('git merge bar/foo').and_return 0
      git.merge_remote 'foo', 'bar'
    end
  end

  context '#diff_remote' do
    it 'generates & calls correct cmd w/ single flag' do
      git.stub(:remotes).and_return []
      git.stub(:exec).with('git fetch --all')
      git.stub(:exec).with('git diff bar/foo --flag').and_return 0
      git.diff_remote 'foo', 'bar', '--flag'
    end

    it 'generates & calls correct cmd w/ multiple flags' do
      git.stub(:remotes).and_return []
      git.stub(:exec).with('git fetch --all')
      git.stub(:exec).with('git diff bar/foo --flag --other').and_return 0
      git.diff_remote 'foo', 'bar', %w(--flag, --other)
    end
  end
end
