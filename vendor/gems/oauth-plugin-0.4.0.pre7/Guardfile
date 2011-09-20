# A sample Guardfile
# More info at http://github.com/guard/guard#readme

guard 'rspec', :version => 2, :cli => '-c' do
  watch(%r{^spec/(.*)_spec.rb})
  watch(%r{^lib/oauth/(.+)\.rb}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')   { "spec" }
end
