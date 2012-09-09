module ReqsHelper
  def active_reqs_class
    if params[:scope]
      "toggle-active-reqs"
    else
      "toggle-active-reqs filter_selected"
    end
  end

  def all_reqs_class
    if params[:scope]
      "toggle-all-reqs filter_selected"
    else
      "toggle-all-reqs"
    end
  end

  def accepted_messages(req)
    req.accepted_bids.map {|bid| "Accepted bid from #{person_link bid.person} at #{time_ago_in_words(bid.accepted_at)} #{t('ago')}"}
  end

  def commitment_messages(req)
    req.committed_bids.map {|bid| "Commitment by #{person_link bid.person} made #{time_ago_in_words(bid.committed_at)} #{t('ago')}"}
  end

  def completed_messages(req)
    req.completed_bids.map {|bid| "Marked completed by #{person_link bid.person} #{time_ago_in_words(bid.completed_at)} #{t('ago')}"}
  end

  def approved_messages(req)
    req.approved_bids.map {|bid| "Confirmed completed by #{person_link req.person} #{time_ago_in_words(bid.approved_at)} #{t('ago')}"}
  end

  def formatted_req_categories(categories)
    (categories.map(&:to_s).join("<br>") + "<br>").html_safe
  end
end
