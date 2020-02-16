clearing :on

guard :minitest do
  watch(%r{^spec/(.+)_spec\.rb})
  watch(%r{^lib/(.+)\.rb}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/(spec_helper|factory)\.rb}) { 'spec' }
  watch(%r{^spec/macros/(.+).rb}) { 'spec' }
end