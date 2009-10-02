class Transact < Exchange
  extend PreferencesHelper
  attr_accessor :to, :callback_url, :redirect_url
  attr_accessible :to, :callback_url, :redirect_url

  after_create :perform_callback

  def save_req(req, person = self.customer)
    req.name = 'miscellaneous' if req.name.blank? # XML creation might not set this
    req.estimated_hours = self.amount
    req.due_date = Time.now
    req.person = person
    req.active = false
    req.save!
    self.req = req
  end

  def results
    if new_record?
    {
      :status => 'decline',
      :description => errors.full_messages.join(" ")
    }
    else
    {
      :to => self.to,
      :from => self.customer.email,
      :amount => self.amount.to_s,
      :txn_date => created_at.iso8601,
      :memo => self.metadata.name,
      :txn_id => "http://" + Transact.global_prefs.server_name + "/transacts/#{self.id}",
      :status => 'ok'
    }
    end
  end

  def to_xml(options={})
    results.to_xml(options.merge(:root => "txn"))
  end

  def to_json(options={})
    results.to_json
  end

  protected

  def callback_uri
    @callback_uri ||= URI.parse(self.callback_url) if self.callback_url
  end

  def http
    unless @http
      @http = Net::HTTP.new(callback_uri.host, callback_uri.port)
      @http.use_ssl = true if callback_uri.scheme == "https"
    end
    @http
  end

  def perform_callback
    if self.callback_url
      request = Net::HTTP::Post.new(callback_uri.path+(callback_uri.query || '' ))
      request.set_form_data(results)
      response = http.request(request)
    end
  end
end
