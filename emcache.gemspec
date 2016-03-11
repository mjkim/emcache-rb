# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emcache/version'

Gem::Specification.new do |spec|
  spec.name          = "emcache"
  spec.version       = Emcache::VERSION
  spec.authors       = ["Myungjun Kim"]
  spec.email         = ["niduss@gmail.com"]

  spec.summary       = %q{Emcache: transparent redis cache}
  spec.description   = %q{Emcache}
  spec.homepage      = "https://github.com/mjkim/emcache-rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rubocop", "~> 0.36"
  spec.add_runtime_dependency "redis", "~> 3.2"
  spec.add_runtime_dependency "connection_pool", "~> 2.2"
end
