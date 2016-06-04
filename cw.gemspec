# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name        = 'cw'
  spec.version     = '0.2.1'
  spec.date        = '2016-05-21'
  spec.authors     = ["Martyn Jago"]
  spec.email       = ["martyn.jago@btinternet.com"]
  spec.description = "A ruby library to help learn and practice morse code"
  spec.summary     = "CW tutor / exerciser"
  spec.homepage    = 'http://github.com/mjago/cw'
  spec.files       = `git ls-files`.split($/)
  spec.license     = 'MIT'

  spec.require_paths = ["lib", "audio", "data/text", "test"]

  spec.required_ruby_version = '>= 1.9.3'
  spec.add_runtime_dependency 'feedjira', '>= 2.0.0'
  spec.add_runtime_dependency 'htmlentities', '>= 4.3.4'
  spec.add_runtime_dependency 'paint', '>= 1.0.1'
  spec.add_runtime_dependency 'rake', '>= 11.1.2'
  spec.add_runtime_dependency 'ruby-progressbar', '>= 1.8.1'
  spec.add_runtime_dependency 'sanitize', '>= 4.0.1'
  spec.add_runtime_dependency 'wavefile', '>= 0.7.0'

  spec.add_development_dependency "minitest"
  spec.add_development_dependency "simplecov"
end
