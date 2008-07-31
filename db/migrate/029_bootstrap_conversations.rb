class BootstrapConversations < ActiveRecord::Migration
  def self.up
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
  end
end
