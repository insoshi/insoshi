class AddOauth2Fields < ActiveRecord::Migration
  def self.up
    add_column :oauth_tokens, :scope, :string
    add_column :oauth_tokens, :valid_to, :datetime
  end

  def self.down
    remove_column :oauth_tokens, :valid_to
    remove_column :oauth_tokens, :scope
  end
end
