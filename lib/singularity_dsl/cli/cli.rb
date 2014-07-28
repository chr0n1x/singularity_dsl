# encoding: utf-8

require 'singularity_dsl/application'
require 'singularity_dsl/cli/table'
require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/errors'
require 'singularity_dsl/git_helper'
require 'singularity_dsl/stdout'
require 'thor'

module SingularityDsl
  # CLI
  module Cli
    # CLI Thor app
    class Cli < Thor
      include Errors
      include Stdout
      include Table

      def initialize(*args)
        super
        @diff_list = nil
        @git = GitHelper.new
      end

      class_option :task_path,
                   aliases: '-t',
                   type: :string,
                   desc: 'Directory where custom tasks are defined',
                   default: './.singularity'
      class_option :all_tasks,
                   aliases: '-a',
                   type: :boolean,
                   desc: 'Do not stop on task failure(s), collect all results'
      class_option :script,
                   aliases: '-s',
                   type: :string,
                   desc: 'Specify path to a .singularityrc file',
                   default: './.singularityrc'

      # TASKS COMMAND
      desc 'tasks', 'Available tasks.'
      def tasks
        dsl = Dsl::Dsl.new
        dsl.load_tasks_in_path tasks_path if ::File.exist? tasks_path
        table = task_table
        dsl.task_list.each do |task|
          table.add_row task_row(dsl, task)
        end
        puts table
      end

      # TEST COMMAND
      desc 'test', 'Run singularity script.'
      def test(app = nil)
        app ||= setup_app(Application.new, singularity_script, tasks_path)
        exit(app.run false, options[:all_tasks])
      end

      # BATCH COMMAND
      desc 'batch BATCH_NAME', 'Run single task batch in the script.'
      def batch(batch, app = nil)
        app ||= setup_app(Application.new, singularity_script, tasks_path)
        exit(app.run batch, options[:all_tasks])
      end

      # TEST-MERGE COMMAND
      desc 'testmerge FORK BRANCH INTO_BRANCH [INTO_FORK]',
           'Perform a test merge into the local repo.'
      option :run_task,
             aliases: '-r',
             type: :string,
             desc: 'Run a batch after. If nothing given, script is run as-is',
             default: ''
      def testmerge(git_fork, branch, base_branch, base_fork = nil)
        test_merge git_fork, branch, base_branch, base_fork
        info 'File changesets'
        list_items @git.diff_remote base_branch, base_fork, '--name-status'
        @diff_list = @git.diff_remote base_branch, base_fork, '--name-only'
        @git.remove_remote git_fork
        @git.remove_remote base_fork
        batch target_run_task if options[:run_task]
      end

      private

      def test_merge(git_fork, branch, base_branch, base_fork)
        @git.clean_reset
        @git.add_remote base_fork
        @git.checkout_remote base_branch, base_fork
        @git.add_remote git_fork
        @git.merge_remote branch, git_fork
        @git.install_submodules
      end

      def target_run_task
        target = options[:run_task]
        target = false if target.eql? ''
        target
      end

      def setup_app(app, singularity_script, tasks_path)
        if File.exist? tasks_path
          info "Loading tasks from #{tasks_path}"
          app.load_tasks tasks_path
        end
        unless @diff_list.nil?
          info 'Running with diff-list'
          list_items @diff_list
          app.change_list @diff_list
        end
        info "Loading CI script from #{singularity_script} ..."
        app.load_script singularity_script
        app
      end

      def singularity_script
        File.expand_path options[:script]
      end

      def tasks_path
        File.expand_path options[:task_path]
      end
    end
  end
end
