module OauthHelper
  def dynamic_scope_params(capability)
    capability.action_id == "single_payment" ? " of #{capability.amount}  #{capability.asset}" : ""
  end

  def oauth_scope_class(capability)
    capability.privileged? ? "privileged-scope-action" : "scope-action"
  end
end
