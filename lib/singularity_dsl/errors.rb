# encoding: utf-8

module SingularityDsl
  # error & failure classes / methods
  module Errors
    class ResourceFail < RuntimeError
    end

    class ResourceError < RuntimeError
    end

    def klass_name(obj)
      return obj.class if obj.class < Object
      obj
    end

    def klass_error(klass)
      klass = klass_name klass
      "#{klass} threw an exception while executing"
    end

    def klass_failed(klass)
      klass = klass_name klass
      "#{klass} failed."
    end

    def resource_fail(klass)
      fail ResourceFail, klass_failed(klass)
    end

    def resource_err(klass)
      fail ResourceError, klass_error(klass)
    end
  end
end
