class Admin::FeedPostsController < ApplicationController
  before_filter :login_required, :admin_required
  active_scaffold :feed_post do |config|
    config.label = "Posts"
    config.columns = [:title, :feedid, :date_published, :urls, :categories, :content, :authors]
    config.list.columns = [:title, :date_published]
  end
end
