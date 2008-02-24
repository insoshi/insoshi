class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table "people", :force => true do |t|
      t.string :email, :remember_token
      t.string :crypted_password
      t.datetime :remember_token_expires_at, :last_contacted_at,
                 :last_logged_in_at
      t.timestamps
    end
    add_index :people, :email
  end

  def self.down
    remove_index :people, :email
    drop_table "people"
  end
end
