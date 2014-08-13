# encoding: utf-8

require 'singularity_dsl/application'
require 'singularity_dsl/cli/table'
require 'singularity_dsl/cli/utils'
require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/errors'
require 'singularity_dsl/git_helper'
require 'thor'

module SingularityDsl
  # CLI
  module Cli
    # CLI Thor app
    class Cli < Thor
      include Errors
      include Table
      include Utils

      attr_reader :git

      def initialize(*args)
        super
        @diff_list = nil
        @git = GitHelper.new
        env_vars(options[:env] || [])
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
      class_option :env,
                   type: :array,
                   desc: 'EnvVars to set, formatted as VAR:VAL'
      class_option :flags,
                   type: :array,
                   desc: <<-EOD
Runtime flags to set for use with flag_set?, formatted as VAR:VAL
EOD

      # TASKS COMMAND
      desc 'tasks', 'Available tasks.'
      def tasks
        dsl = Dsl::Dsl.new
        dsl.load_tasks_in_path tasks_path if ::File.exist? tasks_path
        table = task_table
        dsl.task_list.each do |task|
          task_rows(dsl, task).each { |row| table.add_row row }
        end
        puts table
      end

      # TEST COMMAND
      desc 'test', 'Run singularity script.'
      def test(app = nil)
        app ||= setup_app(Application.new,
                          singularity_script,
                          tasks_path,
                          options[:flags] || [])
        exit(app.run false, options[:all_tasks])
      end

      # BATCH COMMAND
      desc 'batch BATCH_NAME',
           'Run single task batch in the .singularityrc script.'
      def batch(batch, app = nil)
        app ||= setup_app(Application.new,
                          singularity_script,
                          tasks_path,
                          options[:flags] || [])
        exit(app.run batch, options[:all_tasks])
      end

      # TEST-MERGE COMMAND
      desc 'testmerge FORK BRANCH INTO_BRANCH [INTO_FORK]',
           'Perform a testmerge into the local repo and then run .singularityrc'
      option :run_task,
             aliases: '-r',
             type: :string,
             desc: 'Run a batch instead, after testmerge.',
             default: ''
      def testmerge(git_fork, branch, base_branch, base_fork = nil)
        @git.merge_refs git_fork, branch, base_branch, base_fork
        @diff_list = diff_list base_branch, base_fork
        remove_remotes git_fork, base_fork
        batch target_run_task if target_run_task
        test unless target_run_task
      end

      private

      def diff_list(ref, url)
        @git.diff_remote ref, url, '--name-only'
      end

      def remove_remotes(*urls)
        urls.each { |url| @git.remove_remote url }
      end

      def target_run_task
        target = options[:run_task]
        target = false if target.eql? ''
        target
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
