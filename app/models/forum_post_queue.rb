class ForumPostQueue < GirlFriday::WorkQueue
  include Singleton

  def initialize
    super(:forum_post, :size => 1) do |msg|
      ForumPost.find(msg[:id]).perform
    end
  end

  def self.push *args
    instance.push *args
  end
end
