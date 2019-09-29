require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['spec/lib/**/*_spec.rb']
  t.verbose = false
  t.warning = true
end

namespace :schema do
  desc "Update OFMX schema"
  task :update do
    `rm -rf schemas/ofmx/0/*`
    `wget http://schema.openflightmaps.org/0/OFMX-CSV-Obstacle.json -P schemas/ofmx/0/ -q --show-progress`
 	  `wget http://schema.openflightmaps.org/0/OFMX-CSV.json -P schemas/ofmx/0/ -q --show-progress`
 	  `wget http://schema.openflightmaps.org/0/OFMX-DataTypes.xsd -P schemas/ofmx/0/ -q --show-progress`
 	  `wget http://schema.openflightmaps.org/0/OFMX-Features.xsd -P schemas/ofmx/0/ -q --show-progress`
 	  `wget http://schema.openflightmaps.org/0/OFMX-Snapshot.xsd -P schemas/ofmx/0/ -q --show-progress`
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

task default: :test
