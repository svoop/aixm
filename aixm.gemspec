# frozen_string_literal: true

require_relative 'lib/aixm/version'

Gem::Specification.new do |spec|
  spec.name        = 'aixm'
  spec.version     = AIXM::VERSION
  spec.summary     = 'Builder for AIXM/OFMX aeronautical information'
  spec.description = <<~END
    Build XML descriptions of aeronautical infrastructure either as AIXM 4.5
    (Aeronautical Information Exchange Model) or OFMX 1 (Open FlightMaps
    eXchange).
  END
  spec.authors     = ['Sven Schwyn']
  spec.email       = ['ruby@bitcetera.com']
  spec.homepage    = 'https://github.com/svoop/aixm'
  spec.license     = 'MIT'

  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    'changelog_uri'     => 'https://github.com/svoop/aixm/blob/main/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/svoop/aixm',
    'documentation_uri' => 'https://www.rubydoc.info/gems/aixm',
    'bug_tracker_uri'   => 'https://github.com/svoop/aixm/issues'
  }

  spec.files         = Dir['lib/**/*', 'schemas/**/*']
  spec.require_paths = %w(lib)
  spec.bindir        = 'exe'
  spec.executables   = %w(ckmid mkmid)

  spec.cert_chain  = ["certs/svoop.pem"]
  spec.signing_key = File.expand_path(ENV['GEM_SIGNING_KEY']) if ENV['GEM_SIGNING_KEY']

  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.rdoc_options    += [
    '--title', 'AIXM/OFMX Builder',
    '--main', 'README.md',
    '--line-numbers',
    '--inline-source',
    '--quiet'
  ]

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_runtime_dependency 'builder', '~> 3'
  spec.add_runtime_dependency 'nokogiri', '~> 1'
  spec.add_runtime_dependency 'dry-inflector', '~> 0'

  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'minitest-sound'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'yard'
end
