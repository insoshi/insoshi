# Where one could write 
#   BroadcastMailer.some_method(*args).deliver
# the same action is performed by GF using
#   BroadcastMailerQueue.some_method(*args)
# 
class BroadcastMailerQueue < GirlFriday::WorkQueue
  include Singleton

  def initialize
    super(:broadcast_mailer, :size => 1) do |msg|
      BroadcastMailer.send(msg[:method], *msg[:args]).deliver
    end
  end

  def self.push *args
    instance.push *args
  end
  
  def self.method_missing(method, *args)
    self.push :method => method, :args => args
  end
end
