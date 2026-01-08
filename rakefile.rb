require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create(:test) do |t|
  t.test_globs = ["spec/**/*_spec.rb"]
  t.verbose = false
  t.warning = !ENV['RUBYOPT']&.match?(/-W0/)
end

namespace :schema do
  desc "Update OFMX schema"
  task :update do
    version = '0.2'
    `rm -rf schemas/ofmx/#{version}/*`
    `wget http://schema.openflightmaps.org/#{version}/OFMX-CSV-Obstacle.json -P schemas/ofmx/#{version}/ -q --show-progress`
 	  `wget http://schema.openflightmaps.org/#{version}/OFMX-CSV.json -P schemas/ofmx/#{version}/ -q --show-progress`
 	  `wget http://schema.openflightmaps.org/#{version}/OFMX-DataTypes.xsd -P schemas/ofmx/#{version}/ -q --show-progress`
 	  `wget http://schema.openflightmaps.org/#{version}/OFMX-Features.xsd -P schemas/ofmx/#{version}/ -q --show-progress`
 	  `wget http://schema.openflightmaps.org/#{version}/OFMX-Snapshot.xsd -P schemas/ofmx/#{version}/ -q --show-progress`
  end
end

namespace :yard do
  desc "Run local YARD documentation server"
  task :server do
    `rm -rf ./.yardoc`
    Thread.new do
      sleep 2
      `open http://localhost:8808`
    end
    `yard server -r`
  end
end

Rake::Task[:test].enhance do
  if ENV['RUBYOPT']&.match?(/-W0/)
    puts "⚠️  Ruby warnings are disabled, remove -W0 from RUBYOPT to enable."
  end
end

task default: :test
