class Geo::Address < ActiveRecord::Base
  belongs_to :user
  belongs_to :state, :class_name => 'Geo::State'
  
  is_indexed 'fields' => ['name', {:field => 'lat', :function_sql => "RADIANS(?)"}, {:field => 'lng', :function_sql => "RADIANS(?)"}],
    'concatenate' => [{'fields' => ['line_1', 'line_2', 'city', 'province_region', 'zip_postal_code'], 'as' => 'content'}],
    'include' => [{'association_name' => 'state', 'field' => 'name', 'as' => 'state'}],
    'delta' => true
end
