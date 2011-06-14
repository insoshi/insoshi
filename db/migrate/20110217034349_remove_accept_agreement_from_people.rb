class RemoveAcceptAgreementFromPeople < ActiveRecord::Migration
  def self.up
    remove_column :people, :accept_agreement
  end

  def self.down
    add_column :people, :accept_agreement, :boolean, :default => true
  end
end
