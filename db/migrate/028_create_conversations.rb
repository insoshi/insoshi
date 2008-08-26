class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      # We only need the id, but the migration chokes if we don't pass a block.
    end
    add_column :communications, :conversation_id, :integer
    add_index :communications, :conversation_id
    system("rake db:conversation_bootstrap") unless Message.count.zero?
  end

  def self.down
    remove_column :communications, :conversation_id
    drop_table :conversations
  end
end
