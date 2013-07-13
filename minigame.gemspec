# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minigame/version'

Gem::Specification.new do |spec|
  spec.name          = "minigame"
  spec.version       = Minigame::VERSION
  spec.authors       = ["Wavell Watson"]
  spec.email         = ["wavell.watson@gmail.com"]
  spec.description   = %q{A game theory library}
  spec.summary       = %q{A minimalistic game theory library that computes nash equilibrium}
  spec.homepage      = "https://github.com/wavell/minigame"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  
end
