# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barrage/version'

Gem::Specification.new do |spec|
  spec.name          = "barrage"
  spec.version       = Barrage::VERSION
  spec.authors       = ["gussan"]
  spec.email         = ["egussan@gmail.com"]
  spec.summary       = %q{Distributed sequence id generator}
  spec.description   = %q{Distributed sequence id generator}
  spec.homepage      = "http://github.com/drecom/barrage"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "3.0.0.beta2"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "redis"
end
