require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.test_files = FileList['spec/lib/**/*_spec.rb']
  t.verbose = false
  t.warning = true
end

desc "Run local YARD documentation server"
task :yard do
  `rm -rf ./.yardoc`
  Thread.new do
    sleep 2
    `open http://localhost:8808`
  end
  `yard server -r`
end  

task default: :test
