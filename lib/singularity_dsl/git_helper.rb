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
      fail 'failed to clean' unless (reset | clean) == 0
    end

    def checkout_remote(branch, remote)
      remote_action branch, remote, 'checkout'
    end

    def merge_remote(branch, url)
      remote_action branch, url, 'merge'
    end

    def diff_remote(branch, url, flags = '')
      flags = flags.join ' ' if flags.kind_of? Array
      cmd = remote_cmd branch, url, "diff #{flags}"
      task = Mixlib::ShellOut.new cmd
      task.run_command
      task.stdout
    end

    private

    def remote_cmd(branch, url, action)
      remote = remote_from_url url
      remote_reset remote, url if remotes.include? remote
      fetch_all
      "git #{action} #{remote}/#{branch}"
    end

    def remote_action(branch, url, action)
      status = exec(remote_cmd branch, url, action)
      fail "failed to #{action}" unless status == 0
      status
    end

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
      (`git remote`.split "\n") - ['origin']
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
