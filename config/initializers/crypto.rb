require 'openssl' 
require 'rails_generator/secret_key_generator'

class LocalEncryptionKey < ActiveRecord::Base
end

module Crypto
  
  def self.create_keys(bits = 1024)
    private_key = OpenSSL::PKey::RSA.new(bits)
    # DO NOT WRITE PERSISTENT DATA TO THE FILESYSTEM
    local_encryption_key = LocalEncryptionKey.find(:first)
    raise "doh!" if nil == local_encryption_key
    local_encryption_key.rsa_private_key = private_key.to_s
    local_encryption_key.rsa_public_key = private_key.public_key.to_s
    local_encryption_key.session_secret = Rails::SecretKeyGenerator.new("insoshi").generate_secret
    local_encryption_key.save!
    private_key
  end
  
  class Key
    def initialize(data)
      @public = (data =~ /^-----BEGIN (RSA|DSA) PRIVATE KEY-----$/).nil?
      @key = OpenSSL::PKey::RSA.new(data)
    end
  
    def self.from_file(filename)    
      raise
      #self.new File.read( filename )
    end

    def self.from_local_key_value( local_key_value )
      self.new local_key_value
    end
  
    def encrypt(text)
      Base64.encode64(@key.send("#{key_type}_encrypt", text))
    end
    
    def decrypt(text)
      @key.send("#{key_type}_decrypt", Base64.decode64(text))
    end
  
    def private?
      !@public
    end
  
    def public?
      @public
    end
    
    def key_type
      @public ? :public : :private
    end
  end
end
