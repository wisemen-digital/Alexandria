# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-alexandria/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-alexandria"
  spec.version       = CocoapodsAlexandria::VERSION
  spec.authors       = ["David Jennes"]
  spec.email         = ["david.jennes@gmail.com"]
  spec.summary       = %q{Alexandria allows for easier integration with XcodeGen, and automatically switches to a "Rome" mode on CI (pre-compile frameworks)}
  spec.homepage      = "https://github.com/appwise-labs/Alexandria"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cocoapods", '~> 1.8'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
