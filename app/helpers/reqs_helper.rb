module ReqsHelper
  def commitment_message(req)
    bid = req.committed_bid
    commitment_time = time_ago_in_words(bid.committed_at)
    "Commitment by #{person_link bid.person} made #{commitment_time} ago"
  end
end
