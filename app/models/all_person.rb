# == Schema Information
# Schema version: 20080916002106
#
# Table name: people
#
#  id                         :integer(4)      not null, primary key
#  email                      :string(255)     
#  name                       :string(255)     
#  remember_token             :string(255)     
#  crypted_password           :string(255)     
#  description                :text            
#  remember_token_expires_at  :datetime        
#  last_contacted_at          :datetime        
#  last_logged_in_at          :datetime        
#  forum_posts_count          :integer(4)      default(0), not null
#  blog_post_comments_count   :integer(4)      default(0), not null
#  wall_comments_count        :integer(4)      default(0), not null
#  created_at                 :datetime        
#  updated_at                 :datetime        
#  admin                      :boolean(1)      not null
#  deactivated                :boolean(1)      not null
#  connection_notifications   :boolean(1)      default(TRUE)
#  message_notifications      :boolean(1)      default(TRUE)
#  wall_comment_notifications :boolean(1)      default(TRUE)
#  blog_comment_notifications :boolean(1)      default(TRUE)
#  email_verified             :boolean(1)      
#  avatar_id                  :integer(4)      
#  identity_url               :string(255)     
#

class AllPerson < Person
  is_indexed :fields => [ 'name', 'description' ]
end
