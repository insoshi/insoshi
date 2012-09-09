class AddPolymorphicMetadataToExchange < ActiveRecord::Migration
  class Exchange < ActiveRecord::Base; end

  def self.up
    add_column :exchanges, :metadata_id, :integer
    add_column :exchanges, :metadata_type, :string
    
    exchanges = Exchange.find(:all)
    exchanges.each do |exchange|
      exchange.metadata_id = exchange.req_id
      exchange.metadata_type = 'Req'
      exchange.save!
    end

    remove_column :exchanges, :req_id
  end

  def self.down
    add_column :exchanges, :req_id, :integer

    exchanges = Exchange.find_by_metadata_type('Req')
    if exchanges
      exchanges.each do
        exchange.req_id = exchange.metadata_id
        exchange.save!
      end
    end

    remove_column :exchanges, :metadata_id
    remove_column :exchanges, :metadata_type
  end
end
