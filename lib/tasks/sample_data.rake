# Provide tasks to load and delete sample user data.
require 'active_record'
require 'active_record/fixtures'

class Array
  def shuffle
    sort_by { rand }
  end
end

DATA_DIRECTORY = File.join(RAILS_ROOT, "lib", "tasks", "sample_data")

namespace :db do
  namespace :sample_data do 
  
    desc "Load sample data"
    task :load => :environment do |t|
      lipsum = File.open(File.join(DATA_DIRECTORY, "lipsum.txt")).read
      create_people
      make_messages(lipsum)
    end
      
    desc "Remove sample data" 
    task :remove => :environment do |t|
      Rake::Task["db:migrate:reset"].invoke
      system("rm -rf public/images/photos/*")
    end
    
    desc "Reload sample data"
    task :reload => :environment do |t|
      Rake::Task["db:migrate:reset"].invoke
      Rake::Task["db:sample_data:load"].invoke
    end
  end
end

def create_people
  [%w(female F), %w(male M)].each do |pair|
    filename = File.join(DATA_DIRECTORY, "#{pair[0]}_names.txt")
    names = File.open(filename).readlines
    password = "foobar"
    photos = Dir.glob("lib/tasks/sample_data/#{pair[0]}_photos/*.jpg").shuffle
    descriptions_filename = File.join(DATA_DIRECTORY, 
                                      "#{pair[0]}_descriptions.txt")
    descriptions = File.open(descriptions_filename).readlines.shuffle
    names.each_with_index do |name, i|
      name.strip!
      person = Person.create!(:email => "#{name.downcase}@michaelhartl.com",
                              :password => password, 
                              :password_confirmation => password,
                              :gender => pair[1])
      # For security, these attributes aren't attr_accessible, so they
      # have to be assigned separately.
      # Now make the person.
      person.update_attributes!(:description => descriptions[i],
                                     :name => name)
      Photo.create!(:uploaded_data => uploaded_file(photos[i], 'image/jpg'),
                    :person => person, :primary => true)
    end
  end
end

def make_messages(text)
  michael = Person.find_by_email("michael@michaelhartl.com")
  senders = Person.find(:all, :limit => 10)
  senders.each do |sender|
    Message.create!(:content => text, :sender => michael,
                    :recipient => sender, :skip_send_mail => true)
    Message.create!(:content => text, :sender => sender,
                    :recipient => michael, :skip_send_mail => true)
  end
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