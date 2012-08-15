FORUM_POST_QUEUE = GirlFriday::WorkQueue.new(:forum_post, :size => 1) do |msg|
  ForumPost.find(msg[:id]).perform
end

REQ_QUEUE = GirlFriday::WorkQueue.new(:req, :size => 1) do |msg|
  Req.find(msg[:id]).perform
end

BROADCAST_EMAIL_QUEUE = GirlFriday::WorkQueue.new(:broadcast_email, :size => 1) do |msg|
  BroadcastEmail.find(msg[:id]).perform
end
