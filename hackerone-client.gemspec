# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hackerone/client/version'

Gem::Specification.new do |spec|
  spec.name          = "hackerone-client"
  spec.version       = Hackerone::Client::VERSION
  spec.authors       = ["Neil Matatall"]
  spec.email         = ["neil.matatall@gmail.com"]

  spec.summary       = %q{A limited client for the HackerOne API}
  spec.homepage      = "https://github.com/oreoshake/hackerone-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "activesupport"
end
