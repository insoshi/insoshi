class User < ActiveRecord::Base
  has_one   :specific_seller, :class_name => "Seller"
  has_one   :address, :class_name => "Geo::Address"

  is_indexed :fields => ['login', 'email', 'deleted'], 
    :include => [{:association_name => 'specific_seller', :field => 'company_name', :as => 'company', :facet => true},
      {:class_name => 'Seller', :field => 'sellers_two.company_name', :as => 'company_two', :facet => true, 'association_sql' => 'LEFT OUTER JOIN sellers AS sellers_two ON users.id = sellers_two.user_id', 'function_sql' => "REPLACE(?, '6', ' replacement ')"}],
    :conditions => "deleted = '0'",
    :delta => {:field => 'created_at'}    
  
  def self.find_all_by_id(*args)
    raise "Wrong finder"
  end
    
  def self.custom_find(*args)
    method_missing(:find_all_by_id, *args)
  end  
  
end
