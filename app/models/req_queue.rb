class ReqQueue < GirlFriday::WorkQueue
  include Singleton

  def initialize
    super(:req, :size => 1) do |msg|
      sleep(1)
      Req.find(msg[:id]).perform
    end
  end

  def self.push *args
    instance.push *args
  end
end
