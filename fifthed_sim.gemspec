# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fifthed_sim/version'

Gem::Specification.new do |spec|
  spec.name          = "fifthed_sim"
  spec.version       = FifthedSim::VERSION
  spec.authors       = ["Anthony Super"]
  spec.email         = ["anthony@noided.media"]

  spec.summary       = %q{A 5th edition D&D encounter simulator}
  spec.description   = %q{This is a simulator to run a D&D encounter. It provides DSL-like tools to describe actions and abilities, and then it will (eventually) play with some degree of AI skill.}
  spec.homepage      = "https://github.com/AnthonySuper/FifthedSim"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
