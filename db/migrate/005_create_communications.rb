class CreateCommunications < ActiveRecord::Migration
  def self.up
    create_table :communications do |t|
    t.text     :content
    t.string   :parent_id
    t.integer  :sender_id
    t.integer  :recipient_id
    t.datetime :sender_deleted_at
    t.datetime :sender_read_at
    t.datetime :recipient_deleted_at
    t.datetime :recipient_read_at
    t.datetime :replied_at
    t.string   :type
    t.timestamps
    end
  end

  def self.down
    drop_table :communications
  end
end
