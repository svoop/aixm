# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aixm/version'

Gem::Specification.new do |spec|
  spec.name          = 'aixm'
  spec.version       = AIXM::VERSION
  spec.authors       = ['Sven Schwyn']
  spec.email         = ['ruby@bitcetera.com']
  spec.description   = %q(Aeronautical Information Exchange Model (AIXM 4.5).)
  spec.summary       = %q(Aeronautical Information Exchange Model (AIXM 4.5).)
  spec.homepage      = 'https://github.com/svoop/aixm'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'minitest-sound'
  spec.add_development_dependency 'minitest-matchers'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'yard'

  spec.add_runtime_dependency 'builder', '~> 3'
  spec.add_runtime_dependency 'nokogiri', '~> 1'
  spec.add_runtime_dependency 'dry-inflector', '~> 0'
end
