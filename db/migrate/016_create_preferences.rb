class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.string :email_domain
      t.string :smtp_server
      t.boolean :email_notifications

      t.timestamps
    end
  end

  def self.down
    drop_table :preferences
  end
end
