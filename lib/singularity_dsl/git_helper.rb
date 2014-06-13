# encoding: utf-8

require 'mixlib/shellout'

module SingularityDsl
  # wrapper class for rugged
  class GitHelper
    attr_reader :dir

    def initialize
      throw 'git not installed' unless git_installed
    end

    def clean_reset
      fail 'failed to clean' unless (reset & clean) == 0
    end

    def checkout(branch, remote)
      status = exec "git checkout origin/#{branch}"
      fail 'failed to checkout' unless status == 0
      status
    end

    def merge(branch, url = nil)
      remote = remote_from_url url
      remote_reset remote, url unless remote == 'origin'
      fetch_all
      status = exec "git merge #{remote}/#{branch}"
      fail 'failed to merge' unless status == 0
      status
    end

    def status
      cmd = 'git status'
      task = Mixlib::ShellOut.new cmd
      task.run_command
      task.stdout
    end

    def diff_remote_branch(branch, url)
      remote = remote_from_url url
      remote_reset remote, url unless remotes.include? remote
      fetch_all
      cmd = "git diff #{remote}/#{branch} --name-status"
      task = Mixlib::ShellOut.new cmd
      task.run_command
      task.stdout
    end

    private

    def remote_from_url(url)
      return 'origin' if url.nil?
      url.split(':').last.gsub('/', '_')
    end

    def remote_reset(remote, url)
      remove_remote remote if remotes.include? remote
      add_remote remote, url
    end

    def fetch_all
      exec 'git fetch --all'
    end

    def add_remote(name, url)
      exec "git remote add #{name} #{url}"
    end

    def remove_remote(remote)
      exec "git remote rm #{remote}"
    end

    def remotes
      `git remote`.split "\n"
    end

    def index_path
      ::File.join(@repo.path, 'index')
    end

    def git_installed
      !`which git`.empty?
    end

    def reset
      exec 'git add . && git reset --hard'
    end

    def clean
      exec 'git clean -fdx'
    end

    def exec(cmd)
      task = Mixlib::ShellOut.new cmd
      task.run_command
      task.exitstatus
    end
  end
end
