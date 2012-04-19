require 'agree2'
class Agree2Token < ConsumerToken
  AGREE2_SETTINGS={:site=>"https://agree2.com"}
  def self.consumer
    @consumer||=OAuth::Consumer.new credentials[:key],credentials[:secret],AGREE2_SETTINGS
  end

  def self.agree2_client
    @agree2_client||=Agree2::Client.new credentials[:key],credentials[:secret]
  end

  def client
    @client||=Agree2Token.agree2_client.user(token,secret)
  end
end