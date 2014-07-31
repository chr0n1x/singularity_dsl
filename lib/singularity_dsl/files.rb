# encoding: utf-8

module SingularityDsl
  # File helper fx mixin
  module Files
    private

    def files_in_path(path, extension = false)
      paths = [path] if ::File.file? path
      paths = dir_glob path if ::File.directory? path
      paths ||= []
      paths = filter_ext paths, extension if extension
      paths
    end

    def dir_glob(dir)
      dir = ::File.join dir, '**'
      ::Dir.glob dir
    end

    def filter_ext(path_list, ext)
      path_list.select { |file| file.match(/\.#{ext}$/) }
    end
  end
end
