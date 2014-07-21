# encoding: utf-8

module SingularityDsl
  # File helper fx mixin
  module Files
    private

    def files_in_path(path)
      paths = [path] if ::File.file? path
      paths = dir_glob path if ::File.directory? path
      paths ||= []
      paths
    end

    def dir_glob(dir)
      dir = ::File.join dir, '**'
      ::Dir.glob dir
    end
  end
end
