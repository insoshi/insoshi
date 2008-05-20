# Provide tasks to load and delete sample user data.
require 'active_record'
require 'active_record/fixtures'

#DATA_DIRECTORY = File.join(RAILS_ROOT, "lib", "tasks", "sample_data")

namespace :db do
  namespace :demo_data do 
  
    desc "Load demo data"
    task :load => :environment do |t|
      create_demo_people
      make_demo_connections
      # make_messages(@lipsum)
      # make_forum_posts
      # make_blog_posts
      # make_feed   
    end
      
    desc "Remove demo data" 
    task :remove => :environment do |t|
      Rake::Task["db:migrate:reset"].invoke
      # Blow away the Ferret index.
      system("rm -rf index/")
      # Remove images to avoid accumulation.
      system("rm -rf public/photos")
    end
    
    desc "Reload demo data"
    task :reload => :environment do |t|
      Rake::Task["db:demo_data:remove"].invoke
      Rake::Task["install"].invoke
      Rake::Task["db:demo_data:load"].invoke
    end
    

  end
end


def create_demo_people
  Person.create!(:email => "guest@example.com",
                 :password => "foobar",
                 :password_confirmation => "foobar",
                 :name => "Guest User",
                 :description => "This is the guest user's description.")
  description = "This is a desription for "
  %w[male female].each do |gender|
    filename = File.join(DATA_DIRECTORY, "#{gender}_names.txt")
    names = File.open(filename).readlines
    password = "foobar"
    photos = Dir.glob("lib/tasks/sample_data/#{gender}_photos/*.jpg").shuffle
    names.each_with_index do |name, i|
      name.strip!
      person = Person.create!(:email => "#{name.downcase}@example.com",
                              :password => password, 
                              :password_confirmation => password,
                              :name => name,
                              :description => "#{description} #{name}.")
      Photo.create!(:uploaded_data => uploaded_file(photos[i], 'image/jpg'),
                    :person => person, :primary => true)
    end
  end
end   

def make_demo_connections
  person = default_demo_person
  people = Person.find(:all) - [person]
  people.each do |contact|
    Connection.connect(contact, person, send_mail = false)
  end
end

# 
# def make_messages(text)
#   michael = default_person
#   senders = Person.find(:all, :limit => 10)
#   senders.each do |sender|
#     subject = some_text(SMALL_STRING_LENGTH)
#     Message.create!(:subject => subject, :content => text, 
#                     :sender => sender, :recipient => michael,
#                     :send_mail => false)
#     Message.create!(:subject => subject, :content => text, 
#                     :sender => michael, :recipient => sender,
#                     :send_mail => false)
#   end
# end
# 
# def make_forum_posts
#   forum = Forum.find(:first)
#   people = [default_person] + default_person.contacts
#   (1..11).each do |n|
#     name = some_text(rand(Topic::MAX_NAME))
#     topic = forum.topics.create(:name => name, :person => people.pick,
#                                 :created_at => rand(10).hours.ago)
#     11.times do
#       topic.posts.create(:body => @lipsum, :person => people.pick,
#                          :created_at => rand(10).hours.ago)
#     end
#   end
# end
# 
# def make_blog_posts
#   3.times do
#     default_person.blog.posts.create!(:title => some_text(rand(25)),
#       :body => some_text(rand(MEDIUM_TEXT_LENGTH)))
#   end
#   default_person.contacts.each do |contact|
#     contact.blog.posts.create!(:title => some_text(rand(25)),
#       :body => some_text(rand(MEDIUM_TEXT_LENGTH)))
#   end
# end
# 
# # Make a less-boring sample feed.
# def make_feed
#   # Mix up activities for variety.
#   default_person.activities.each do |activity|
#     activity.created_at = rand(20).hours.ago
#     activity.save!
#   end
# end
# 
# def uploaded_file(filename, content_type)
#   t = Tempfile.new(filename.split('/').last)
#   t.binmode
#   path = File.join(RAILS_ROOT, filename)
#   FileUtils.copy_file(path, t.path)
#   (class << t; self; end).class_eval do
#     alias local_path path
#     define_method(:original_filename) {filename}
#     define_method(:content_type) {content_type}
#   end
#   return t
# end
# 
def default_demo_person
  Person.find_by_name("Guest User")
end
# 
# # Return some random text.
# def some_text(n, default = "foobar")
#   text = @lipsum.split.shuffle.join(' ')[0...n].strip.capitalize
#   text.blank? ? default : text
# end