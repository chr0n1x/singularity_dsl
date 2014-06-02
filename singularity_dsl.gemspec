# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'singularity_dsl/version'

Gem::Specification.new do |spec|
  spec.name          = "singularity_dsl"
  spec.version       = SingularityDsl::VERSION
  spec.authors       = ["chr0n1x"]
  spec.email         = ["heilong24@gmail.com"]
  spec.description   = %q{DSL for your SingularityDsl instance.}
  spec.summary       = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.add_dependency "thor"
  #spec.add_dependency "mixlib-config", "~> 2.0"
  #spec.add_dependency "mixlib-log", "~> 1.3"
  #spec.add_dependency "mixlib-shellout", "~> 1.4"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
