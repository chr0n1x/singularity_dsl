# encoding: utf-8

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # Utility functions mixin module
    module Utils
      def task_name(klass)
        klass.to_s.split(':').last
      end

      def task(klass)
        task_name(klass).downcase.to_sym
      end

      def task_list
        klasses = []
        SingularityDsl.constants.each do |klass|
          klass = SingularityDsl.const_get(klass)
          next unless klass.is_a? Class
          next unless klass < Task
          klasses.push klass
        end
        klasses
      end
    end
  end
end
