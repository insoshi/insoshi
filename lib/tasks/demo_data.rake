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
      make_demo_activities
      Preference.find(:first).update_attributes(:demo => true)
    end
      
    desc "Remove demo data" 
    task :remove => :environment do |t|
      Rake::Task["db:migrate:reset"].invoke
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
  description = "This is a description for "
  %w[male female].each do |gender|
    filename = File.join(DATA_DIRECTORY, "#{gender}_names.txt")
    names = File.open(filename).readlines[0...10]
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

def make_demo_activities
  person = default_demo_person
  people = Person.find(:all) - [person]
  Message.create(:subject => "The message subject",
                 :content => "The message content.",
                 :sender => people.rand,
                 :recipient => person)
  person.comments.create(:body => "A wall comment!",
                         :commenter => people.rand)
  forum = Forum.find(:first)
  topic = forum.topics.create(:name => "A forum topic",
                              :person => people.rand)
  topic.posts.create(:body => "This is the post body.",
                     :person => people.rand)
  people.rand.blog.posts.create(:title => "A blog post",
                                :body => "This is a blog post!")
end

def default_demo_person
  Person.find_by_name("Guest User")
end