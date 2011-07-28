guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
#guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('spec/spec_helper.rb')
  watch('app/controllers/transacts_controller.rb')
end
