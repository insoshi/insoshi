class AddExchangeToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :exchange_id, :integer
  end
end
