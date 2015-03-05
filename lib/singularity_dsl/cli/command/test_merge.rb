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

        def perform_merge(git_fork, branch, base_branch, base_fork = nil)
          git.merge_refs git_fork, branch, base_branch, base_fork
          @diff_list += get_diff_list(base_branch, base_fork)
          remove_remotes git_fork, base_fork
          self
        end

        def execute
          inject_diff_list
          super
        end

        def batch
          target = options[:run_task]
          target = false if target.nil? || target.strip.eql?('')
          target
        end

        private

        def inject_diff_list
          return unless diff_list.empty?
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
