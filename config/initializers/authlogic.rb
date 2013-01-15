module Authlogic
  module CryptoProviders
    class Bace
      class << self
        def encrypt(*tokens)
          plain = tokens[0]
          salt = tokens[1]
          hash = Digest::SHA2.new
          hash << salt
          hash << plain
          hash.to_s
        end
        
        # Does the crypted password match the tokens? Uses the same tokens that were used to encrypt.
        def matches?(crypted, *tokens)
          encrypt(*tokens) == crypted
        end
      end
    end
  end
end
