# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'odps/version'

Gem::Specification.new do |spec|
  spec.name = "aliyun-odps-ruby-sdk"
  spec.version = AliODPS::VERSION
  spec.authors = ["ZhangZhaoyuan"]
  spec.email = ["doraemon.zh@gmail.com"]
  spec.license = 'Apache-2.0'

  spec.summary = %q{Ruby SDK for aliyun odps}
  spec.homepage = "https://github.com/hot88zh/aliyun-odps-ruby-sdk"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "faraday"
end
