class OauthToken < ActiveRecord::Base
  belongs_to :client_application
  belongs_to :person
  belongs_to :group
  validates_uniqueness_of :token
  validates_presence_of :client_application, :token, :group
  before_validation :generate_keys, :on => :create
  before_create :validate_scope
  
  def invalidated?
    invalidated_at != nil
  end
  
  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end
  
  def authorized?
    authorized_at != nil && !invalidated?
  end
    
  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end

  def validate_scope
    # make sure there is at most one instance of each query parameter
    scope_hash.each_value {|v| return false if v.length > 1}
  end

  def scope_hash
    scope_uri = URI.parse(self.scope)
    CGI::parse(scope_uri.query)
  end
    
  def asset
    scope_hash['asset'][0]
  end

  def amount
    scope_hash['amount'][0]
  end

  def authorized_for?(requested_amount)
    ['single_payment','recurring_payment'].include?(action_id) && requested_amount <= amount.to_f && !invalidated?
  end

  # XXX assuming just one scope for now
  def action_id
    action['_id']
  end

  def action_name
    action['name']
  end

  def action_icon_uri
    action['icon_uri']
  end

  def action
    @action ||= JSON.parse(File.read(RAILS_ROOT + '/public' + URI.parse(self.scope).path))['action']
  end

  protected
  
  def generate_keys
    self.token = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end
end
