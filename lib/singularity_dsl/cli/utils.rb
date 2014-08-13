# encoding: utf-8

require 'singularity_dsl/stdout'

module SingularityDsl
  # CLI
  module Cli
    # util functions
    module Utils
      include Stdout

      private

      def env_vars(vals)
        vals.each do |pair|
          key = pair.split(':', 2).first
          val = pair.split(':', 2).last
          ENV[key] = val
        end
      end

      def setup_app(app, singularity_script, tasks_path, flags = [])
        inject_flags app, flags
        inject_diff_list app
        if ::File.exist? tasks_path
          info "Loading tasks from #{tasks_path}"
          app.load_tasks tasks_path
        end
        info "Loading CI script from #{singularity_script} ..."
        app.load_script singularity_script
        app
      end

      def inject_flags(app, flags = [])
        flags.each do |pair|
          key = pair.split(':', 2).first
          val = pair.split(':', 2).last
          app.runner.dsl.flag key if key == val
          app.runner.dsl.flag key, val unless key == val
        end
        app
      end

      def inject_diff_list(app)
        unless @diff_list.nil?
          info 'Running with diff-list'
          list_items @diff_list
          app.change_list @diff_list
        end
        app
      end
    end
  end
end
