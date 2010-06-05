class Admin::ExchangesController < ApplicationController
  before_filter :login_required, :admin_required
  active_scaffold :exchange do |config|
    config.label = "Exchanges"
    list.columns.exclude :audits
    show.columns.exclude :audits
  end

  protected

end
