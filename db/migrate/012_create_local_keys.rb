class CreateLocalKeys < ActiveRecord::Migration
  include Crypto
  def self.up
    # Identifier for the tracker
    File.open("identifier", "w") do |f|
      f.write UUID.new
    end unless File.exist?("identifier")
    # RSA keys for user authentication
    Crypto.create_keys
  end

  def self.down
  end
end
