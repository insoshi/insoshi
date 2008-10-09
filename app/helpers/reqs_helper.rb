module ReqsHelper
  def commitment_message(req)
    bid = req.committed_bid
    commitment_time = time_ago_in_words(bid.committed_at)
    "Commitment by #{person_link bid.person} made #{commitment_time} ago"
  end

  def completed_message(req)
    bid = req.committed_bid
    completed_time = time_ago_in_words(bid.completed_at)
    "Marked completed by #{person_link bid.person} #{completed_time} ago"
  end
end
