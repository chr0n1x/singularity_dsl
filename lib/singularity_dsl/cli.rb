# encoding: utf-8

require 'singularity_dsl/cli/command'
require 'singularity_dsl/version'

require 'thor'

module SingularityDsl
  module Cli
    # CLI (Thor) interface for CLI commands
    class Cli < Thor
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
      class_option :verbose,
                   type: :boolean,
                   desc: 'Turn on verbose logging.'
      class_option :flags,
                   type: :array,
                   desc: <<-EOD
Runtime flags to set for use with flag_set?, formatted as VAR:VAL
EOD

      def initialize(*args)
        super
        env_vars(options[:env] || [])
      end

      map %w(--version -v) => :__print_version
      desc '--version, -v', 'print the version'
      def __print_version
        puts "Singularity Runner & DSL v#{::SingularityDsl::VERSION}"
      end

      desc 'tasks', 'Available tasks.'
      def tasks
        Command::Tasks.new(options).execute
      end

      desc 'test', 'Run singularity script.'
      def test
        Command::Test.new(options).execute
      end

      desc 'batch BATCH_NAME',
           'Run single task batch in the .singularityrc script.'
      def batch(batch)
        Command::Test.new(options.merge(batch: batch).freeze).execute
      end

      desc 'testmerge FORK BRANCH INTO_BRANCH [INTO_FORK]',
           'Perform a testmerge into the local repo and then run .singularityrc'
      option :run_task,
             aliases: '-r',
             type: :string,
             desc: 'Run a batch instead, after testmerge.',
             default: ''
      option :bootstrap_cwd,
             aliases: '-b',
             type: :boolean,
             desc: 'Bootstrap local directory by cloning & setting up the repo.'
      def testmerge(git_fork, branch, base_branch, base_fork = nil)
        Command::TestMerge.new(options).tap do |cmd|
          cmd.bootstrap_cwd(base_fork)
            .set_fork_env(git_fork, branch)
            .perform_merge(git_fork, branch, base_branch, base_fork)
            .execute
        end
      end

      private

      def env_vars(vals)
        vals.each do |pair|
          key = pair.split(':', 2).first
          val = pair.split(':', 2).last
          ENV[key] = val
        end
      end
    end
  end
end
