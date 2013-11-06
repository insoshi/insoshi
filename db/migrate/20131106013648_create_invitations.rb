class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :group_id
      t.integer :person_id
      t.datetime :accepted_at
      t.timestamps
    end
  end
end
