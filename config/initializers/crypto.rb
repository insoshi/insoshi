require 'openssl' 

module Crypto
  
  def self.create_keys(priv = "rsa_key", pub = "#{priv}.pub", bits = 1024)
    private_key = OpenSSL::PKey::RSA.new(bits)
    File.open(priv, "w+") { |fp| fp << private_key.to_s }
    File.open(pub,  "w+") { |fp| fp << private_key.public_key.to_s }    
    private_key
  end
  
  class Key
    def initialize(data)
      @public = (data =~ /^-----BEGIN (RSA|DSA) PRIVATE KEY-----$/).nil?
      @key = OpenSSL::PKey::RSA.new(data)
    end
  
    def self.from_file(filename)    
      filename = <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQCxyp7GituWNhUHa6CZXpo8y4nlh7gohHTHZlP5vVZf9PMCD6/a
9bnOuS4gMnCcvgIB2bn5Qv6CAsvOF5opB428P8R+b676GrrEUvGLQ0Pm7OMfr7wc
s37V1kcXbS2hlLwA+oX3lxjSXBRk/6pkTStfILPRBIfzJtm29f1egImeUQIDAQAB
AoGBAJNRcX7SUGGHLqWXaNusp+D4RqsKam4oUxtmju7BFHEuZq2ukei889l3V+EV
6nn2d3NRFeiUuo7AAmAi7npQ5/9SZidw2WehWxGQz9xAR8N44+zRL1dKSYgBfD3J
P4zea9e9KFchFgP1mcajEU2fvk8mrqavGjCKWX6z0Bt323yBAkEA348oNmC59mAJ
kqe6jVv0QZH2H1AYJ5TKm0s3KrukSN6BSaZvye/XjBbaBGHeV31RLDp/kT46gvq6
GPmnCAHfpwJBAMuXRTg+5htKWRegWBoN8hANjXsraX+KUN+Ly2pvK3eluqHwLf+i
ZM7x8eESlu0GYo+QCL/EXhsmTJpEXHfRkUcCQA10KA9dstNI5EqXHXr0Vba8eftY
bpuzMJ434JIJyNE50r4D7iZQ8L/VgDlTSnYpbIEk5BhxjkPjot9t5sdslXECQCea
CTDjq0brs2DRI9INnGRa/oZS73aLpSeWvb66WS4w4pjVa10qbYmDrpUlVI5Oi6V5
UvpabCPD02q+mW4FKckCQQC/7ndoi0tfx5ChPDGKHnDcf0eiBajIDwOAaS8VUj4f
kQ4pAU1Pgji2XcQsQe63o8rRMWA6ZP1JU2FjlJaJx96T
-----END RSA PRIVATE KEY-----
EOF
      self.new filename
      #self.new File.read( filename )
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
