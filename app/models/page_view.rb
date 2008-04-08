# == Schema Information
# Schema version: 15
#
# Table name: page_views
#
#  id          :integer(11)     not null, primary key
#  user_id     :integer(11)     
#  request_url :string(200)     
#  session     :string(32)      
#  ip_address  :string(16)      
#  referer     :string(200)     
#  user_agent  :string(200)     
#  created_at  :datetime        
#  updated_at  :datetime        
#

class PageView < ActiveRecord::Base  
end
