class CreateLocalEncryptionKeys < ActiveRecord::Migration
  include Crypto

  class LocalEncryptionKey < ActiveRecord::Base
  end

  def self.up
    create_table :local_encryption_keys do |t|
      t.text :rsa_private_key
      t.text :rsa_public_key
    end

    # RSA keys for user authentication
    # XXX hack! until authentication is replaced, rsa keys are now going
    # into database instead of files for diskless deploy.
    LocalEncryptionKey.create!
    Crypto.create_keys
  end

  def self.down
    drop_table :local_encryption_keys
  end
end
