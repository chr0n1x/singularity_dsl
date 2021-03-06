# encoding: utf-8

require 'mixlib/shellout'
require 'singularity_dsl/stdout'

module SingularityDsl
  # wrapper class for rugged
  class GitHelper
    include SingularityDsl::Stdout

    attr_reader :dir, :verbose

    def initialize
      throw 'git not installed' unless git_installed
      @verbose = false
    end

    def log(flags = '')
      exec("git log #{flags}", true)
    end

    def cwd_is_git_repo
      ::File.exist? "#{::Dir.pwd}/.git"
    end

    def clone_to_cwd(repo_url)
      exec("git clone #{repo_url} .")
    end

    def clean_reset
      raise 'failed to clean' unless (reset | clean) == 0
    end

    def checkout_remote(branch, remote)
      remote_action branch, remote, 'checkout'
    end

    def install_submodules
      exec 'git submodule update --init --recursive'
    end

    def merge_remote(branch, url)
      remote_action branch, url, 'merge'
    end

    def diff_remote(branch, url, flags = '')
      flags = flags.join ' ' if flags.is_a? Array
      cmd = remote_cmd branch, url, "diff #{flags}"
      task = Mixlib::ShellOut.new cmd
      task.run_command
      task.stdout.split("\n").map(&:strip)
    end

    def add_remote(url)
      remote = remote_from_url url
      exec("git remote add #{remote} #{url}") if url
      fetch_all
    end

    def remove_remote(url)
      remote = remote_from_url url
      return 0 if remote.eql? 'origin'
      exec("git remote rm #{remote}")
    end

    def merge_refs(git_fork, branch, base_branch, base_fork)
      clean_reset
      add_remote base_fork
      checkout_remote base_branch, base_fork
      add_remote git_fork
      merge_remote branch, git_fork
    end

    def verbosity(level)
      @verbose = level.is_a?(Fixnum) && level > 0
      @verbose = level if level.is_a? TrueClass
    end

    private

    def remote_cmd(branch, url, action)
      remote = remote_from_url url
      "git #{action} #{remote}/#{branch}"
    end

    def remote_action(branch, url, action)
      status = exec(remote_cmd(branch, url, action))
      raise "failed to #{action}" unless status == 0
      status
    end

    def remote_from_url(url)
      return 'origin' if url.nil? || !url
      url.split(':').last.tr('/', '_')
    end

    def fetch_all
      exec 'git fetch --all'
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
      exec 'git clean -ffdx'
    end

    def exec(cmd, output = false)
      task = Mixlib::ShellOut.new cmd
      if @verbose
        info cmd
        task.live_stream = STDOUT
      end
      task.run_command
      return task.stdout if output
      return task.exitstatus unless output
    end
  end
end
