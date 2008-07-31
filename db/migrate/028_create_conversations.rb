class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      # We only need the id, but the migration chokes if we don't pass a block.
    end
    add_column :communications, :conversation_id, :integer
  end

  def self.down
    remove_column :communications, :conversation_id
    drop_table :conversations
  end
end
