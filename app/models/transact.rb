class Transact < ExchangeAndFee
  extend PreferencesHelper
  attr_accessor :to, :memo, :callback_url, :redirect_url
  attr_accessible :callback_url, :redirect_url

  after_create :perform_callback

  module Scopes
    def by_newest
      order('created_at DESC').limit(10)
    end
  end

  extend Scopes

  def create_req(memo)
    req = Req.new
    req.name = memo.blank? ? 'miscellaneous' : memo 
    req.group = group
    req.person = customer
    req.estimated_hours = amount
    req.due_date = Time.now
    req.biddable = false
    req.save!
    req
  end

  def results
    if new_record?
    {
      :status => 'decline',
      :description => errors.full_messages.join(" ")
    }
    else
    {
      :to => worker.email,
      :from => customer.email,
      :amount => amount.to_s,
      :txn_date => created_at.iso8601,
      :note => metadata.name,
      :txn_id => "http://" + Transact.global_prefs.server_name + "/transacts/#{id}",
      :status => 'ok'
    }
    end
  end

  def to_xml(options={})
    results.to_xml(options.merge(:root => "txn"))
  end

  def as_json(options={})
    results.as_json
  end
  
  def paid_fees 
    tc_transaction_fee = 0
    cash_transaction_fee = 0
    customers_plan = Person.find(worker_id).fee_plan
    
    if customers_plan
      cash_fees_sum = customers_plan.fixed_transaction_stripe_fees.sum(:amount)
      cash_fees_perc_sum = customers_plan.percent_transaction_stripe_fees.sum(:percent)
      cash_transaction_fee = cash_fees_sum + (cash_fees_perc_sum * amount)
      tc_fees_sum = customers_plan.fixed_transaction_fees.sum(:amount)
      tc_fees_perc_sum = customers_plan.percent_transaction_fees.sum(:percent)
      tc_transaction_fee = tc_fees_sum + (tc_fees_perc_sum * amount)
    end
    {:trade_credits => tc_transaction_fee, :cash => cash_transaction_fee, :txn_id => self.id }
  end

  protected

  def callback_uri
    @callback_uri ||= URI.parse(callback_url) if callback_url
  end

  def http
    unless @http
      @http = Net::HTTP.new(callback_uri.host, callback_uri.port)
      @http.use_ssl = true if callback_uri.scheme == "https"
    end
    @http
  end

  def perform_callback
    if !callback_url.blank?
      request = Net::HTTP::Post.new(callback_uri.path+(callback_uri.query || '' ))
      request.set_form_data(results)
      response = http.request(request)
    end
  end
  
end
