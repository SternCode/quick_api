# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quick/api/version'

Gem::Specification.new do |spec|
  spec.name          = "quick-api"
  spec.version       = Quick::Api::VERSION
  spec.authors       = ["SternCode"]
  spec.email         = ["sterncode@gmail.com"]
  spec.description   = %q{Make your API rest quick}
  spec.summary       = %q{Make your API rest quick}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
