class Admin::PeopleController < ApplicationController
  before_filter :login_required, :admin_required
  active_scaffold :person do |config|
    config.actions.exclude :delete
    config.label = "People"
    config.columns = [:name, :email, :phone, :admin, :deactivated, :email_verified, :last_logged_in_at]
    config.list.columns = [:name, :email, :phone, :admin, :deactivated, :email_verified, :last_logged_in_at]
    config.create.columns = [:name, :email, :phone, :password, :password_confirmation] 
    config.update.columns = [:name, :admin, :email, :phone, :password, :password_confirmation, :deactivated, :email_verified] 
    config.nested.add_link('Addresses', [:addresses])
  end

  # NOTE: index was removed from original insoshi to allow active scaffold to be default index
  #       and update was moved into app people controller  

  protected

  def before_create_save(record)
    record.email_verified = true
    record.accept_agreement = true
  end
end
