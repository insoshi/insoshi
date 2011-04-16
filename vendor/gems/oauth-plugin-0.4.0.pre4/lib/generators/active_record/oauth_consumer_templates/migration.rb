class CreateOauthConsumerTokens < ActiveRecord::Migration
  def self.up
    
    create_table :consumer_tokens do |t|
      t.integer :user_id
      t.string :type, :limit => 30
      t.string :token, :limit => 1024 # This has to be huge because of Yahoo's excessively large tokens
      t.string :secret
      t.timestamps
    end
    
    add_index :consumer_tokens, :token, :unique => true
    
  end

  def self.down
    drop_table :consumer_tokens
  end

end
