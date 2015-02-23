# encoding: utf-8

module SingularityDsl
  # DSL classes & fxs
  module Dsl
    # methods & data to store & describe changesets
    module Changeset
      attr_writer :changeset

      @changeset = []
      @existing = nil

      def files_changed?(types)
        types = [*types]
        @changeset ||= []
        types.any? do |type|
          @changeset.any? do |file|
            file.match("\.#{type}$") || type == file
          end
        end
      end

      def changed_files(types)
        types = [*types]
        @changeset ||= []
        types.flat_map do |type|
          existing_files.select do |file|
            file.match("\.#{type}$") || type == file
          end
        end.sort
      end

      private

      def existing_files
        if @existing.nil?
          @existing = @changeset.select { |file| ::File.exist?(file) }
        end
        @existing
      end
    end
  end
end
