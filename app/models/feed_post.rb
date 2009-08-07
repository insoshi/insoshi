require 'feed-normalizer'
require 'open-uri'

class FeedPost < ActiveRecord::Base
  extend PreferencesHelper

  class << self
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
            post.last_updated = entry.last_updated
            post.save
          end
        end
        new_ids.count
      rescue
        nil
      end
    end
  end
end
