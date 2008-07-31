class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      # We only need the id.
    end
    # Bootstrap any existing messages with conversation ids.
    Message.find(:all) do |message|
      
    end
  end

  def self.down
    drop_table :conversations
  end
end
