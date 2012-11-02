require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminAddToMailchimpList
end

module RailsAdmin
  module Config
    module Actions
      class AddToMailchimpList < RailsAdmin::Config::Actions::Base
        # see http://apidocs.mailchimp.com/api/rtfm/exceptions.field.php
        LIST_ALREADYSUBSCRIBED = "214"

        def self.subscribe(list_id,person)
          gb = Gibbon.new
          result = gb.list_subscribe({:id => list_id, :email_address => person.email, :double_optin => false, :send_welcome => Preference.first.mailchimp_send_welcome, :merge_vars => {:FNAME => person.name, :LNAME => ""}}) 
          if true == result
            person.update_attribute(:mailchimp_subscribed, true)
            flash_message = ""
          else
            Rails.logger.info "Error! #{result['error']}"
            flash_message = result['error']
          end
        rescue Gibbon::MailChimpError => e
          error_code=e.message.match(/\(code ([0-9]+)\)/)
          if LIST_ALREADYSUBSCRIBED == error_code[1] 
            person.update_attribute(:mailchimp_subscribed, true)
            flash_message = "#{person.name} is already subscribed to mailchimp list!"
          else
            flash_message = result['error']
          end
        end

        register_instance_option :visible? do
          authorized? && !Preference.first.mailchimp_list_id.blank? && !bindings[:object].mailchimp_subscribed
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-check'
        end

        register_instance_option :controller do
          Proc.new do
            # XXX railsadmin UI is sending http request twice. ignore the redundant pjax request.
            unless request.headers['X-PJAX']
              flash_message = AddToMailchimpList.subscribe(Preference.first.mailchimp_list_id,@object)
              if "" == flash_message
                flash[:notice] = "Added #{@object.name} to mailchimp list!"
              else
                flash[:error] = flash_message
              end
              redirect_to back_or_index
            end
          end
        end

      end
    end
  end
end
