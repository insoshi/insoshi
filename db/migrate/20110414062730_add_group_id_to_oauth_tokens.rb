class AddGroupIdToOauthTokens < ActiveRecord::Migration
  def self.up
    add_column :oauth_tokens, :group_id, :integer
  end

  def self.down
    remove_column :oauth_tokens, :group_id
  end
end
