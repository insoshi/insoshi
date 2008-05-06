require 'active_record'
require 'active_record/fixtures'

namespace :feed do
  desc "Remove duplicate feed items"
  task :undup => :environment do |t|
    feed = Feed.find(:all, :order => 'person_id, activity_id')
    dups = []
    feed.each_with_index do |item, i|
      dups.push(item) if i > 0 and same?(item, feed[i-1])
    end
    puts "Destroying #{dups.length} duplicate feed items"
    dups.each { |duplicate| duplicate.destroy }
  end
  
  def same?(item1, item2)
    item1.person_id == item2.person_id && 
    item1.activity_id == item2.activity_id
  end
end