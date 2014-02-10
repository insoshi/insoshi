require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Load the custom matchers in spec/matchers
  matchers_path = File.dirname(__FILE__) + "/matchers"
  matchers_files = Dir.entries(matchers_path).select {|x| /\.rb\z/ =~ x}
  matchers_files.each do |path|
    require File.join(matchers_path, path)
  end

  # Custom matchers includes
  config.include(CustomModelMatchers)

  config.global_fixtures = :client_applications, :conversations, :feeds, :forums, :neighborhoods, :oauth_nonces, :oauth_tokens, :offers, :people, :posts, :preferences, :topics

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Simulate an uploaded file.
  def uploaded_file(filename, content_type = "image/png")
    t = Tempfile.new(filename)
    t.binmode
    path = File.join(::Rails.root, "spec", "images", filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end).class_eval do
      alias local_path path
      define_method(:original_filename) {filename}
      define_method(:content_type) {content_type}
    end
    return t
  end

  def mock_photo(options = {})
    photo = mock_model(Photo)
    photo.stub!(:public_filename).and_return("photo.png")
    photo.stub!(:primary).and_return(options[:primary])
    photo.stub!(:primary?).and_return(photo.primary)
    photo
  end

  # Write response body to output file.
  # This can be very helpful when debugging specs that test HTML.
  def output_body(response)
    File.open("tmp/index.html", "w") { |f| f.write(response.body) }
  end

  # Make a user an admin.
  # All fixture people are not admins by default, to protect against mistakes.
  def admin!(person)
    person.admin = true
    person.save!
    person
  end

  # This is needed to get RSpec to understand link_to(..., person).
  def polymorphic_path(args)
    "http://a.fake.url"
  end

  def enable_email_notifications
    Preference.find(:first).update_attributes(:email_verifications => true)
  end
end

end

Spork.each_run do
  # This code will be run each time you run your specs.
end
