# == Schema Information
#
# Table name: local_encryption_keys
#
#  id              :integer          not null, primary key
#  rsa_private_key :text
#  rsa_public_key  :text
#

class LocalEncryptionKey < ActiveRecord::Base
end
