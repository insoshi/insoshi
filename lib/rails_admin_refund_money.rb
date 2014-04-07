require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminAddToMailchimpList
end

module RailsAdmin
  module Config
    module Actions
      class RefundMoney < RailsAdmin::Config::Actions::Base      
        
        register_instance_option :visible? do
          authorized? and !bindings[:object].status.include?("refunded")
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-repeat'
        end
        
        register_instance_option :http_methods do
          [:get,:post]
        end

        register_instance_option :route_fragment do
          'refund_money'
        end

        register_instance_option :controller do
         Proc.new do
          # XXX railsadmin UI is sending http request twice. ignore the redundant pjax request.
          unless request.headers['X-PJAX']
            # First call should render a view, which will allow for choosing refund amount.
            # Filter param, so refund must be greater than 0 and lesser than amount.
            if request.get?
              respond_to do |format|
                format.html { render @action.template_name }
              end
            elsif request.post? and params[:amount].present?
              amount = params[:amount]              
              # Replace "," with "." for number calculations. "14,25".to_f => 14, not 14.25.
              amount.gsub!(/,/, '.')
              amount = amount.to_f
              # 0.50 is Stripe's minimum amount and certainly we don't want any negative or too big numbers.
              if amount >= 0.50 and amount <= @object.amount                
                flash[:alert] = StripeOps.refund_charge(@object.stripe_id, amount)
                redirect_to back_or_index
              else
                flash[:error] = "The amount you want to refund is not correct. Minimum is 0.50"
                redirect_to :back
              end
            else
              flash[:error] = "Amount can't be blank."
              redirect_to :back
            end
          end
         end
        end
      end
      
         
   end
 end
end