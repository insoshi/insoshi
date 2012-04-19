require 'opentransact'
class OpenTransactToken < ConsumerToken

#  def self.server
#    @consumer||=OpenTransact::Server.new credentials
#  end

#  def self.consumer
#    @consumer||=server.consumer
#  end

  def client
    @client ||= OpenTransact::Client.new self.class.credentials.merge( {:token=>token, :secret=>secret})
  end
end