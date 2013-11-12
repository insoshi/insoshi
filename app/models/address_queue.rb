class AddressQueue < GirlFriday::WorkQueue
  include Singleton

  def initialize
    super(:address, :size => 1) do |msg|
      Address.find(msg[:id]).perform
    end
  end

  def self.push *args
    instance.push *args
  end
end
