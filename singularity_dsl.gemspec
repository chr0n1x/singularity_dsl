# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'singularity_dsl/version'

Gem::Specification.new do |spec|
  spec.name          = 'singularity_dsl'
  spec.version       = SingularityDsl::VERSION
  spec.authors       = ['chr0n1x']
  spec.email         = ['heilong24@gmail.com']
  spec.description   = %q{DSL for your SingularityCI instance.}
  spec.summary       = %q{}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'json', '~> 1.0'
  spec.add_dependency 'mixlib-shellout', '~> 1.6.0'
  spec.add_dependency 'rainbow', '~> 2.0.0'
  spec.add_dependency 'rake', '~> 10.3'
  spec.add_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'rubocop', '~> 0.24'
  spec.add_dependency 'terminal-table', '~> 1.4'
  spec.add_dependency 'thor', '~> 0.19'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'gem-release'
end
