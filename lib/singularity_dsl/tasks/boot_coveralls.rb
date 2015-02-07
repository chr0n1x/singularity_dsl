# encoding: utf-8

require 'coveralls'
require 'singularity_dsl/stdout'
require 'singularity_dsl/task'

# bootstrap coveralls in the current runtime
class BootCoveralls < SingularityDsl::Task
  include SingularityDsl::Stdout

  attr_reader :env

  def initialize(&block)
    # TODO: there may be others...?
    @required_envs = %w(COVERALLS_REPO_TOKEN)
    @env = 'singularity-coveralls'
    @no_fail = true
    super(&block)
  end

  def token(token)
    ENV['COVERALLS_REPO_TOKEN'] = token
  end

  def report_endpoint(endpoint)
    ENV['COVERALLS_ENDPOINT'] = endpoint
  end

  def no_fail(switch)
    fail 'no_fail must be bool' unless bool? switch
    @no_fail = switch
  end

  def cover_all_things!
    ::Coveralls.wear!
  end

  def execute
    # never fail run!
    unless env_ok
      info 'Skipping coveralls'
      return
    end

    begin
      ENV['CI_NAME'] ||= env
      ENV['CI'] ||= env
      cover_all_things!
    rescue ::StandardError => e
      info e.to_s
      raise e unless @no_fail
    end
  end

  def description
    'Boots a custom Coveralls ENVironment'
  end

  private

  def env_ok
    ok = true
    @required_envs.each do |var|
      unless ENV.key? var
        info "Missing ENV variable: #{var}"
        ok = false
      end
    end
    ok
  end
end
