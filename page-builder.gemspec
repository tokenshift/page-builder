# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'page_builder'

Gem::Specification.new do |spec|
  spec.name          = "page-builder"
  spec.version       = PageBuilder::VERSION
  spec.authors       = ["Nathan Clark"]
  spec.email         = ["Nathan.Clark@tokenshift.com"]
  spec.description   = %q{Simple static site generator.}
  spec.summary       = %q{Simple static site generator.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "slim", "~> 2.0.2"
  spec.add_runtime_dependency "kramdown", "~> 1.2.0"
end
