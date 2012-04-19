require 'oauth/controllers/consumer_controller'

# Goes through the entries in your OAUTH_CREDENTIALS and either loads the class required
# or subclasses ConsumerToken with the name.
#
# So an entry called "my_service" will create a class MyServiceToken which you can
# connect with has_one to your user model.
if defined? ConsumerToken && defined? OAUTH_CREDENTIALS
  require File.join(File.dirname(__FILE__), 'services', 'oauth2_token')

  OAUTH_CREDENTIALS.each do |key, value|
    class_name=value[:class_name]||"#{key.to_s.classify}Token"
    unless Object.const_defined?(class_name.to_sym)
      if File.exists?(File.join(File.dirname(__FILE__), "services","#{key.to_s}_token.rb"))
        Rails.logger.info File.join(File.dirname(__FILE__), "services","#{key.to_s}_token")
        require File.join(File.dirname(__FILE__), "services","#{key.to_s}_token")
      else
        begin
          # Let Rails auto-load from the models folder
          eval class_name
        rescue NameError
          super_class = value[:super_class]||value[:oauth_version].to_i>=2 ? "Oauth2Token" : "ConsumerToken"
          eval "class #{class_name} < #{super_class} ;end"
        end
      end
    end
  end
end