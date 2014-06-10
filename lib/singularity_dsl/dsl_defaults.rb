# encoding: utf-8

module SingularityDsl
  # default methods to be mixed into DSL objects
  module DslDefaults
    attr_reader :error_proc, :fail_proc, :success_proc, :always_proc

    def on_error(&block)
      @error_proc = Proc.new(&block)
    end

    def on_fail(&block)
      @fail_proc = Proc.new(&block)
    end

    def on_success(&block)
      @success_proc = Proc.new(&block)
    end

    def always(&block)
      @always_proc = Proc.new(&block)
    end
  end
end
