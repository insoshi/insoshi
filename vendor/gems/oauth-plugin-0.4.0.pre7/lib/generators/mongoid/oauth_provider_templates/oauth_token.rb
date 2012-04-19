class OauthToken
  include Mongoid::Document
  include Mongoid::Timestamps

  field :token, :type => String
  field :secret, :type => String
  field :callback_url, :type => String
  field :verifier, :type => String
  field :scope, :type => String
  field :authorized_at, :type => Time
  field :invalidated_at, :type => Time
  field :expires_at, :type => Time

  index :token, :unique => true

  referenced_in :user
  referenced_in :client_application

  validates_uniqueness_of :token
  validates_presence_of :client_application, :token
  before_validation :generate_keys, :on => :create

  def invalidated?
    !invalidated_at.nil?
  end

  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end

  def authorized?
    !authorized_at.nil? && !invalidated?
  end

  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end

  protected
  def generate_keys
    self.token = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end
end
