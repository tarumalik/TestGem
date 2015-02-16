# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'TestGem/version'

Gem::Specification.new do |spec|
  spec.name          = "TestGem"
  spec.version       = TestGem::VERSION
  spec.authors       = ["QA Automation Group @ Yellow Pages Group"]
  spec.email         = ["taru.malik@ypg.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{Ruby Package to help the wayward QA Tester}
  spec.description   = %q{Ruby Package to help the wayward QA Tester}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "savon", "~> 2.8.0"
  spec.add_runtime_dependency "json", "~> 1.8.1"
  spec.add_runtime_dependency "rest-client", "~> 1.6.7"
  spec.add_runtime_dependency "rspec", "~> 3.1.0"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
