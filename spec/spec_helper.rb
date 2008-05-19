# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
include AuthenticatedTestHelper

Spec::Runner.configure do |config|
  # Active Record configuration
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  # Load the custom matchers in spec/matchers
  matchers_path = File.dirname(__FILE__) + "/matchers"
  matchers_files = Dir.entries(matchers_path).select {|x| /\.rb\z/ =~ x}
  matchers_files.each do |path|
    require File.join(matchers_path, path)
  end
  
  # Custom matchers includes
  config.include(CustomModelMatchers)
  
  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  config.global_fixtures = :all
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses its own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  
  # Simulate an uploaded file.
  def uploaded_file(filename, content_type = "image/png")
    t = Tempfile.new(filename)
    t.binmode
    path = File.join(RAILS_ROOT, "spec", "images", filename)
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
