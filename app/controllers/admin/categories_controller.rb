class Admin::CategoriesController < ApplicationController
  layout "admin/admin"
  before_filter :login_required, :admin_required
  active_scaffold :category do |config|
    config.actions.exclude :delete
    config.label = "Categories"
    config.columns = [:name, :description, :parent]
    config.list.columns = [:name, :description,]
    config.create.columns = [:name, :description, :parent]
    config.update.columns = [:name, :description, :parent]
    config.columns[:parent].form_ui = :select
  end
end
