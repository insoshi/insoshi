# == Schema Information
#
# Table name: feed_posts
#
#  id             :integer          not null, primary key
#  feedid         :string(255)
#  title          :string(255)
#  urls           :string(255)
#  categories     :string(255)
#  content        :text
#  authors        :string(255)
#  date_published :datetime
#  last_updated   :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

require 'feed-normalizer'
require 'open-uri'

class FeedPost < ActiveRecord::Base
  extend PreferencesHelper

  class << self
    def posts(page = 1)
      paginate(:page => page, :order => 'date_published DESC')
    end

    def update_posts
      posts = find(:all, :select => "feedid") 
      post_ids = posts.map {|p| p.feedid}

      begin
        feed = FeedNormalizer::FeedNormalizer.parse open(global_prefs.blog_feed_url)

        feed_ids = feed.entries.map {|e| e.id}
        new_ids = feed_ids - post_ids

        feed.entries.each do |entry|
          if new_ids.include? entry.id
            post = FeedPost.new()
            post.feedid = entry.id
            post.title = entry.title
            post.urls = entry.urls
            post.categories = entry.categories
            post.content = entry.content
            post.authors = entry.authors
            post.date_published = entry.date_published
            #post.last_updated = entry.last_updated
            post.save
          end
        end
        new_ids.length
      rescue
        nil
      end
    end
  end
end
