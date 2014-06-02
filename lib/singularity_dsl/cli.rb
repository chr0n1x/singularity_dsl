# encoding: utf-8

require "thor"

module SingularityDsl
  class Cli < Thor
    attr_reader :config_hash

    def initialize(*args)
      super
      @config_hash = {}
    end

    # rubocop:disable AlignHash
    class_option :script, aliases: '-s', type: :string,
      desc: 'Specify path to a .singularity.rb file'
    class_option :debug, aliases: '-d', type: :boolean,
      desc: 'Turn on debug mode'

    desc 'test', 'Run singularity script'
    def test
      puts 'hi'
    end
  end
end
