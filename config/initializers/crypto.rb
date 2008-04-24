require 'openssl' 

module Crypto
  
  def self.create_keys(priv = "rsa_key", pub = "#{priv}.pub", bits = 1024)
    private_key = OpenSSL::PKey::RSA.new(bits)
    File.open(priv, "w+") do |fp|
      fp << private_key.to_s
    end unless File.exist?(priv)
    File.open(pub,  "w+") do |fp|
      fp << private_key.public_key.to_s
    end unless File.exist?(pub)
    private_key
  end
  
  class Key
    def initialize(data)
      @public = (data =~ /^-----BEGIN (RSA|DSA) PRIVATE KEY-----$/).nil?
      @key = OpenSSL::PKey::RSA.new(data)
    end
  
    def self.from_file(filename)    
      self.new File.read( filename )
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