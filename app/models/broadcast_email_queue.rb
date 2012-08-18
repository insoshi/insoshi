class BroadcastEmailQueue < GirlFriday::WorkQueue
  include Singleton

  def initialize
    super(:broadcast_email, :size => 1) do |msg|
      BroadcastEmail.find(msg[:id]).perform
    end
  end

  def self.push *args
    instance.push *args
  end
end
