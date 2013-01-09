class Capability < ActiveRecord::Base
  belongs_to :group
  belongs_to :oauth_token

  before_create :validate_scope_and_assign_group

  def invalidated?
    invalidated_at != nil
  end
  
  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end

  def amount_user_authorized
    action_id == "all_access" ? 1.0/0 : amount.to_f
  end

  def authorized_for?(requested_amount)
    ['single_payment','recurring_payment','all_access'].include?(action_id) && requested_amount <= amount_user_authorized && !invalidated?
  end

  def single_payment?
    action_id == 'single_payment'
  end

  def privileged?
    action_id == 'read_all_payments'
  end

  def asset(scope)
    scope_uri = URI.parse(scope)
    query_hash = scope_uri.query.nil? ? {} : CGI::parse(scope_uri.query)
  end

  def validate_scope_and_assign_group
    # make sure there is at most one instance of each query parameter
    scope_hash.each_value {|v| return false if v.length > 1}
    self.group = asset.empty? ? nil : Group.find_by_asset(asset)
    true
  end

  def can_list?(g)
    ['read_payments','read_all_payments','all_access'].include?(action_id) && (self.group == g || self.group.nil?)
  end

  def can_list_all?(g)
    ['read_all_payments','all_access'].include?(action_id) && (self.group == g || self.group.nil?)
  end

  def can_pay?(g)
    ['single_payment','recurring_payment','all_access'].include?(action_id) && (self.group == g || self.group.nil?) && !invalidated?
  end

  def can_list_wallet_contents?
    ['read_wallet','all_access'].include?(action_id)
  end

  def scope_hash
    scope_uri = URI.parse(self.scope)
    scope_uri.query.nil? ? {} : CGI::parse(scope_uri.query)
  end
    
  def asset
    asset_array = scope_hash['asset']
    asset_array.nil? ? "" : asset_array[0]
  end

  def amount
    amount_array = scope_hash['amount']
    amount_array.nil? ? "" : amount_array[0]
  end

  def long_amount
    amount.blank? ? "" : "#{amount} "
  end

  def long_asset
    asset.blank? ? "" : " (#{long_amount}#{asset})"
  end

  def long_action_name
    action_name + long_asset
  end

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
    @action ||= JSON.parse(File.read(::Rails.root.to_s + '/public' + URI.parse(self.scope).path))['action']
  end
end
