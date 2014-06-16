# encoding: utf-8

module SingularityDsl
  # methods & data to store & describe changesets
  module DslChangeset
    attr_writer :changeset

    @changeset = []
    @existing = nil

    def files_changed?(types)
      types = [*types]
      types.any? do |type|
        @changeset.any? { |file| file.match("\.#{type}$") }
      end
    end

    def changed_files(types)
      types = [*types]
      types.flat_map do |type|
        existing_files.select { |file| file.match("\.#{type}$") }
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
