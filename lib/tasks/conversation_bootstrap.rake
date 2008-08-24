namespace :db do
  desc "Recycle the database by dropping, recreating, and migrating"
  task :conversation_bootstrap => :environment  do
    messages = Message.find(:all, :order => :created_at)
    unless messages.empty?
      puts "Bootstrapping existing messages by adding conversation ids."
      messages.each do |message|
        parent = message.parent
        conversation = parent.nil? ? Conversation.create : 
                                     parent.reload.conversation
        message.update_attributes(:conversation => conversation)
      end
    end
  end
end