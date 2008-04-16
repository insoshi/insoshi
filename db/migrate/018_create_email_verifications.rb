class CreateEmailVerifications < ActiveRecord::Migration
  def self.up
    create_table :email_verifications do |t|
      t.integer :person_id
      t.string :code

      t.timestamps
    end
  end

  def self.down
    drop_table :email_verifications
  end
end
