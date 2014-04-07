require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdmin
  module Config
    module Actions
      class DisputeLink < RailsAdmin::Config::Actions::Base      
        
        register_instance_option :visible? do
          authorized? and bindings[:object].status == 'disputed'
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-comment'
        end
        
        register_instance_option :http_methods do
          [:get]
        end

        register_instance_option :controller do
         Proc.new do
           redirect_to @object.dispute_link
         end 
        end
      end
      
         
   end
 end
end