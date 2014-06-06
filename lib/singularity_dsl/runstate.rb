# encoding: utf-8

module SingularityDsl
  # abstraction class for the overall runtime state
  class Runstate
    attr_reader :errors, :failures, :error, :failed

    def initialize
      @error = false
      @errors = []
      @failed = false
      @failures = []
    end

    def add_failure(fail_msg)
      @failed = true
      @failures.push fail_msg
    end

    def add_error(err_msg)
      @error = @failed = true
      @errors.push err_msg
    end
  end
end
