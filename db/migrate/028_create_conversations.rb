class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      # We only need the id, but the migration chokes if we don't pass a block.
    end
    add_column :communications, :conversation_id, :integer
    
    messages = Message.find(:all, :order => :created_at)
    unless messages.empty?
      puts "Bootstrapping existing messages by adding conversation ids."
      messages.each do |message|
        parent = message.parent
        conversation = parent.nil? ? Conversation.create : parent.conversation
        message.update_attributes(:conversation => conversation)
      end
    end
  end

  def self.down
    remove_column :communications, :conversation_id
    drop_table :conversations
  end
end
