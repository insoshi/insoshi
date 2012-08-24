require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminSendBroadcastEmail
end

module RailsAdmin
  module Config
    module Actions
      class SendBroadcastEmail < RailsAdmin::Config::Actions::Base
        register_instance_option :visible? do
          authorized? && !bindings[:object].sent
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :link_icon do
          'icon-check'
        end

        register_instance_option :controller do
          Proc.new do
            @object.update_attribute(:sent, true)
            @object.spew
            flash[:notice] = "Sending #{object.subject}."
            redirect_to back_or_index
          end
        end
      end
    end
  end
end
