module OauthHelper
  def dynamic_scope_params(capability)
    capability.action_id == "single_payment" ? " of #{capability.amount}  #{capability.asset}" : ""
  end
end
