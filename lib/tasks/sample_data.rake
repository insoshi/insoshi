# Provide tasks to load and delete sample user data.
require 'active_record'
require 'active_record/fixtures'

DATA_DIRECTORY = File.join(RAILS_ROOT, "lib", "tasks", "sample_data")

namespace :db do
  namespace :sample_data do 
  
    desc "Load sample data"
    task :load => :environment do |t|
      Rake::Task["install"].invoke      
      @lipsum = File.open(File.join(DATA_DIRECTORY, "lipsum.txt")).read
      make_preferences
      create_people
      make_connections
      make_messages(@lipsum)
      make_forum_posts
      make_blog_posts
      make_feed
      puts "Completed loading sample data."
      puts "Run 'rake ultrasphinx:bootstrap' to start Sphinx search"
    end
      
    desc "Remove sample data" 
    task :remove => :environment do |t|
      system("rake db:migrate VERSION=0")
      # Remove images to avoid accumulation.
      system("rm -rf public/photos")
    end
    
    desc "Reload sample data"
    task :reload => :environment do |t|
      Rake::Task["db:sample_data:remove"].invoke
      # We use a system call to reload the Rails environment.
      # Otherwise, the db:migrate might use the *old* schema, causing
      # an error when creating the admin user.
      system("rake db:sample_data:load")
    end
  end
end

def create_people
  %w[male female].each do |gender|
    filename = File.join(DATA_DIRECTORY, "#{gender}_names.txt")
    names = File.open(filename).readlines
    password = "foobar"
    photos = Dir.glob("lib/tasks/sample_data/#{gender}_photos/*.jpg").shuffle
    last_names = @lipsum.split
    names.each_with_index do |name, i|
      name.strip!
      full_name = "#{name} #{last_names.pick.capitalize}"
      person = Person.create!(:email => "#{name.downcase}@example.com",
                              :password => password, 
                              :password_confirmation => password,
                              :name => full_name,
                              :description => @lipsum)
      person.last_logged_in_at = Time.now
      person.save
      gallery = Gallery.unsafe_create(:person => person, :title => 'Primary',
                                      :description => 'My first gallery')
      photo = uploaded_file(photos[i], 'image/jpg')
      Photo.unsafe_create!(:uploaded_data => photo, :person => person,
                           :primary => true, :avatar => true,
                           :gallery => gallery)

    end
  end
end

def make_connections
  person = default_person
  people = Person.find(:all) - [person]
  people.shuffle[0..20].each do |contact|
    Connection.request(contact, person, send_mail = false)
    sometimes(0.5) { Connection.accept(person, contact) }
  end
end

def make_messages(text)
  michael = default_person
  senders = Person.find(:all, :limit => 10)
  senders.each do |sender|
    subject = some_text(SMALL_STRING_LENGTH)
    Message.unsafe_create!(:subject => subject, :content => text, 
                           :sender => sender, :recipient => michael,
                           :send_mail => false,
                           :conversation => Conversation.new)
    Message.unsafe_create!(:subject => subject, :content => text, 
                           :sender => michael, :recipient => sender,
                           :send_mail => false,
                           :conversation => Conversation.new)
  end
end

def make_forum_posts
  forum = Forum.find(:first)
  people = [default_person] + default_person.contacts
  (1..11).each do |n|
    name = some_text(rand(Topic::MAX_NAME))
    topic = forum.topics.unsafe_create(:name => name, :person => people.pick,
                                :created_at => rand(10).hours.ago)
    11.times do
      topic.posts.unsafe_create(:body => @lipsum, :person => people.pick,
                         :created_at => rand(10).hours.ago)
    end
  end
end

def make_blog_posts
  3.times do
    default_person.blog.posts.unsafe_create!(:title => some_text(rand(25)),
      :body => some_text(rand(MEDIUM_TEXT_LENGTH)))
  end
  default_person.contacts.each do |contact|
    contact.blog.posts.unsafe_create!(:title => some_text(rand(25)),
      :body => some_text(rand(MEDIUM_TEXT_LENGTH)))
  end
end

# Make a less-boring sample feed.
def make_feed
  # Mix up activities for variety.
  default_person.activities.each do |activity|
    activity.created_at = rand(20).hours.ago
    activity.save!
  end
end

def make_preferences
  Preference.create!(:app_name => 'Insoshi', :domain => 'example.com', :smtp_server => 'mail.example.com', :email_notifications => false)
end

def uploaded_file(filename, content_type)
  t = Tempfile.new(filename.split('/').last)
  t.binmode
  path = File.join(RAILS_ROOT, filename)
  FileUtils.copy_file(path, t.path)
  (class << t; self; end).class_eval do
    alias local_path path
    define_method(:original_filename) {filename}
    define_method(:content_type) {content_type}
  end
  return t
end

def default_person
  Person.find_by_email('michael@example.com')  
end

# Return some random text.
def some_text(n, default = "foobar")
  text = @lipsum.split.shuffle.join(' ')[0...n].strip.capitalize
  text.blank? ? default : text
end

# Do something sometimes (with probability p).
def sometimes(p, &block)
  yield(block) if rand <= p
end