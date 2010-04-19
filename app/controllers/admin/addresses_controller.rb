class Admin::AddressesController < ApplicationController
  before_filter :login_required, :admin_required
  active_scaffold :address do |config|
    config.label = 'Addresses'
    config.columns = [:address_line_1, :address_line_2, :address_line_3, :city, :state, :zipcode_plus_4]
    config.columns[:address_line_1].options = { :size => 50, :maxlength => 50 }
    config.columns[:address_line_2].options = { :size => 50, :maxlength => 50 }
    config.columns[:address_line_3].options = { :size => 50, :maxlength => 50 }
    config.columns[:city].options = { :size => 50, :maxlength => 50 }
    config.columns[:state].form_ui = :select
    config.columns[:zipcode_plus_4].options = { :size => 10, :maxlength => 10 }
  end
end
