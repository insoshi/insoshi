class RequestToken < OauthToken
  
  attr_accessor :provided_oauth_verifier
  
  def authorize!(person)
    return false if authorized?
    self.person = person
    self.authorized_at = Time.now
    self.verifier=OAuth::Helper.generate_key(20)[0,20] unless oauth10?
    self.save
  end

  def asset
    scope_uri = URI.parse(self.scope)
    scope_hash = CGI::parse(scope_uri.query)
    scope_hash['asset']
  end

  # XXX assuming just one scope for now
  def action_name
    action['action']['name']
  end

  def action_icon_uri
    action['action']['icon_uri']
  end

  def action
    @action ||= JSON.parse(File.read(RAILS_ROOT + '/public' + URI.parse(self.scope).path))
  end

  def exchange!
    return false unless authorized?
    return false unless oauth10? || verifier==provided_oauth_verifier
    
    RequestToken.transaction do
      access_token = AccessToken.create(:person => person, :group_id => group_id, :scope => scope, :client_application => client_application)
      invalidate!
      access_token
    end
  end
  
  def to_query
    if oauth10?
      super
    else
      "#{super}&oauth_callback_confirmed=true"
    end
  end
  
  def oob?
    self.callback_url=='oob'
  end
  
  def oauth10?
    (defined? OAUTH_10_SUPPORT) && OAUTH_10_SUPPORT && self.callback_url.blank?
  end

end
