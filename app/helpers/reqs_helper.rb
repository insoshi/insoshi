module ReqsHelper
  def list_link_with_active(name, options = {}, html_options = {}, &block)
    opts = {}
    opts.merge!(:class => "active") if current_page?(options)
    content_tag(:li, link_to(name, options, html_options, &block), opts)
  end

  def accepted_messages(req)
    bids = req.bids.find_all {|bid| bid.accepted_at != nil}
    messages = bids.map {|bid| "Accepted bid from #{person_link bid.person} at #{time_ago_in_words(bid.accepted_at)} ago"}
  end

  def commitment_messages(req)
    bids = req.bids.find_all {|bid| bid.committed_at != nil}
    messages = bids.map {|bid| "Commitment by #{person_link bid.person} made #{time_ago_in_words(bid.committed_at)} ago"}
  end

  def completed_messages(req)
    bids = req.bids.find_all {|bid| bid.completed_at != nil}
    messages = bids.map {|bid| "Marked completed by #{person_link bid.person} #{time_ago_in_words(bid.completed_at)} ago"}
  end

  def approved_messages(req)
    bids = req.bids.find_all {|bid| bid.approved_at != nil}
    messages = bids.map {|bid| "Confirmed completed by #{person_link req.person} #{time_ago_in_words(bid.approved_at)} ago"}
  end
end
