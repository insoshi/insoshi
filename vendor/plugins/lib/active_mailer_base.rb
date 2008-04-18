

class ActionMailer::Base

  helper ActionView::Helpers::UrlHelper

  def generic_mailer(options)
    @recipients = options[:recipients] || MAILER_TO_ADDRESS
    @from = options[:from] || MAILER_FROM_ADDRESS
    @cc = options[:cc] || ""
    @bcc = options[:bcc] || ""
    @subject = options[:subject] || ""
    @body = options[:body] || {}
    @headers = options[:headers] || {}
    @charset = options[:charset] || "utf-8"
    @content_type = options[:content_type] || "text/plain"
  end
  
  
  def self.add_recipients(addresses, address)
    if addresses.blank?
      address
    else
      addresses << ";#{address}"
    end
  end
  
=begin
#add blocks like this to controlers
class ContactMailer < ActionMailer::Base
  def contact_us(options)
    self.generic_mailer(options)
  end
end
  

#call like this
  ContactMailer.deliver_contact_us(
   :recipients => "x@x.com",
   :body => { 
               :name => params[:name],
               :phone => params[:phone],
               :email => params[:email],
               :message => params[:message]
             },
   :from => "y@y.com"
)
=end

end
