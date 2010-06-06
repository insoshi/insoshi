class Admin::GroupsController < ApplicationController
  before_filter :login_required, :admin_required
  active_scaffold :group do |config|
    config.label = "Groups"
    config.columns = [:name]
  end

  protected

end
