class CreateStatuses < ActiveRecord::Migration
  def self.up
    transaction do
      create_table :statuses do |t|
        t.string :name
        t.timestamps
      end

      # Populate status table.
      Status.reset_column_information
      BID_STATUS.each do |s|
        bid_status = Status.new( :name => s )
        bid_status.save
      end
    end
  end

  def self.down
    drop_table :statuses
  end

  BID_STATUS = [
    'inactive',
    'offered',
    'accepted',
    'committed',
    'completed',
    'satisfied',
    'not satisfied'
    ]
end
