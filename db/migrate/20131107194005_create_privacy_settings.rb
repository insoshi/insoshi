class CreatePrivacySettings < ActiveRecord::Migration
  def change
    create_table :privacy_settings do |t|
      t.integer :group_id
      t.boolean :viewable_reqs, :default => true
      t.boolean :viewable_offers, :default => true
      t.boolean :viewable_forum, :default => true
      t.boolean :viewable_members, :default => true

      t.timestamps
    end
  end
end
