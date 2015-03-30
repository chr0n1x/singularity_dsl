# encoding: utf-8

require 'singularity_dsl/cli/command/test'
require 'singularity_dsl/git_helper'

module SingularityDsl
  module Cli
    module Command
      # testmerge command
      # perform a merge, inject a changeset, run test command
      class TestMerge < Test
        attr_reader :git, :diff_list

        def initialize(options)
          super options
          @diff_list = []
          @git = SingularityDsl::GitHelper.new
          @git.verbosity options[:verbose]
        end

        def bootstrap_cwd(repo_url)
          return self unless options[:bootstrap_cwd]
          git.clean_reset if git.cwd_is_git_repo
          git.clone_to_cwd(repo_url) unless git.cwd_is_git_repo
          git.install_submodules
          self
        end

        def set_fork_env(fork_url, branch)
          git.add_remote(fork_url)
          git.checkout_remote(branch, fork_url)
          setup_git_env(branch)
          git.remove_remote(fork_url)
          self
        end

        def perform_merge(fork_url, branch, base_branch, repo_url = nil)
          git.merge_refs fork_url, branch, base_branch, repo_url
          git.install_submodules
          @diff_list += get_diff_list(base_branch, repo_url)
          remove_remotes fork_url, repo_url
          self
        end

        def execute
          super { |app| inject_diff_list app }
        end

        def batch
          target = options[:run_task]
          target = false if target.nil? || target.strip.eql?('')
          target
        end

        private

        def git_env_flags
          {
            'GIT_AUTHOR_NAME' => "--pretty=format:'%aN'",
            'GIT_AUTHOR_EMAIL' => "--pretty=format:'%ae'",
            'GIT_COMMITTER_NAME' => "--pretty=format:'%cN'",
            'GIT_COMMITTER_EMAIL' => "--pretty=format:'%ce'",
            'GIT_ID' => "--pretty=format:'%H'",
            'GIT_MESSAGE' => "--pretty=format:'%s'"
          }
        end

        def setup_git_env(branch)
          git_env_flags.each { |k, f| ENV[k] = git.log("-1 #{f}") }
          ENV['GIT_BRANCH'] = branch
        end

        def inject_diff_list(app)
          return if diff_list.empty?
          info 'Running with diff-list'
          list_items diff_list
          app.change_list diff_list
        end

        def get_diff_list(ref, url)
          git.diff_remote ref, url, '--name-only'
        end

        def remove_remotes(*urls)
          urls.each { |url| git.remove_remote url }
        end
      end
    end
  end
end
