# This module is responsible for adding OpenID functionality to Authlogic. Checkout the README for more info and please
# see the sub modules for detailed documentation.
module AuthlogicOpenid
  # This module is responsible for adding in the OpenID functionality to your models. It hooks itself into the
  # acts_as_authentic method provided by Authlogic.
  module ActsAsAuthentic
    # Adds in the neccesary modules for acts_as_authentic to include and also disabled password validation if
    # OpenID is being used.
    def self.included(klass)
      klass.class_eval do
        extend Config
        add_acts_as_authentic_module(Methods, :prepend)
      end
    end
    
    module Config
      # Some OpenID providers support a lightweight profile exchange protocol, for those that do, you can require
      # certain fields. This is convenient for new registrations, as it will basically fill out the fields in the
      # form for them, so they don't have to re-type information already stored with their OpenID account.
      #
      # For more info and what fields you can use see: http://openid.net/specs/openid-simple-registration-extension-1_0.html
      #
      # * <tt>Default:</tt> []
      # * <tt>Accepts:</tt> Array of symbols
      def openid_required_fields(value = nil)
        rw_config(:openid_required_fields, value, [])
      end
      alias_method :openid_required_fields=, :openid_required_fields
      
      # Same as required_fields, but optional instead.
      #
      # * <tt>Default:</tt> []
      # * <tt>Accepts:</tt> Array of symbols
      def openid_optional_fields(value = nil)
        rw_config(:openid_optional_fields, value, [])
      end
      alias_method :openid_optional_fields=, :openid_optional_fields
    end
    
    module Methods
      # Set up some simple validations
      def self.included(klass)
        return if !klass.column_names.include?("openid_identifier")
        
        klass.class_eval do
          validates_uniqueness_of :openid_identifier, :scope => validations_scope, :if => :using_openid?
          validate :validate_openid
          validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_with_openid?)
          validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_with_openid?)
          validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_with_openid?)
        end
      end
      
      # Set the openid_identifier field and also resets the persistence_token if this value changes.
      def openid_identifier=(value)
        write_attribute(:openid_identifier, value.blank? ? nil : OpenID.normalize_url(value))
        reset_persistence_token if openid_identifier_changed?
      rescue OpenID::DiscoveryFailure => e
        @openid_error = e.message
      end
      
      # This is where all of the magic happens. This is where we hook in and add all of the OpenID sweetness.
      #
      # I had to take this approach because when authenticating with OpenID nonces and what not are stored in database
      # tables. That being said, the whole save process for ActiveRecord is wrapped in a transaction. Trying to authenticate
      # with OpenID in a transaction is not good because that transaction be get rolled back, thus reversing all of the OpenID
      # inserts and making OpenID authentication fail every time. So We need to step outside of the transaction and do our OpenID
      # madness.
      #
      # Another advantage of taking this approach is that we can set fields from their OpenID profile before we save the record,
      # if their OpenID provider supports it.
      def save(perform_validation = true, &block)
        return false if perform_validation && block_given? && authenticate_with_openid? && !authenticate_with_openid
        result = super
        yield(result) if block_given?
        result
      end
      
      private
        def authenticate_with_openid
          @openid_error = nil
          
          if !openid_complete?
            session_class.controller.session[:openid_attributes] = attributes_to_save
          else
            map_saved_attributes(session_class.controller.session[:openid_attributes])
            session_class.controller.session[:openid_attributes] = nil
          end

          options = {
           :required => self.class.openid_required_fields,
           :optional => self.class.openid_optional_fields,
           :return_to => session_class.controller.url_for(:for_model => "1"),
           :method => :post }
          
          session_class.controller.send(:authenticate_with_open_id, openid_identifier, options) do |result, openid_identifier, registration|
            if result.unsuccessful?
              @openid_error = result.message
            else
              self.openid_identifier = openid_identifier
              map_openid_registration(registration)
            end
            
            return true
          end
          
          return false
        end
        
        # Override this method to map the OpenID registration fields with fields in your model. See the required_fields and
        # optional_fields configuration options to enable this feature.
        #
        # Basically you will get a hash of values passed as a single argument. Then just map them as you see fit. Check out
        # the source of this method for an example.
        def map_openid_registration(registration) # :doc:
          self.name ||= registration[:fullname] if respond_to?(:name) && !registration[:fullname].blank?
          self.first_name ||= registration[:fullname].split(" ").first if respond_to?(:first_name) && !registration[:fullname].blank?
          self.last_name ||= registration[:fullname].split(" ").last if respond_to?(:last_name) && !registration[:last_name].blank?
        end
        
        # This method works in conjunction with map_saved_attributes.
        #
        # Let's say a user fills out a registration form, provides an OpenID and submits the form. They are then redirected to their
        # OpenID provider. All is good and they are redirected back. All of those fields they spent time filling out are forgetten
        # and they have to retype them all. To avoid this, AuthlogicOpenid saves all of these attributes in the session and then
        # attempts to restore them. See the source for what attributes it saves. If you need to block more attributes, or save
        # more just override this method and do whatever you want.
        def attributes_to_save # :doc:
          attrs_to_save = attributes.clone.delete_if do |k, v|
            [:id, :password, crypted_password_field, password_salt_field, :persistence_token, :perishable_token, :single_access_token, :login_count, 
              :failed_login_count, :last_request_at, :current_login_at, :last_login_at, :current_login_ip, :last_login_ip, :created_at,
              :updated_at, :lock_version].include?(k.to_sym)
          end
          attrs_to_save.merge!(:password => password, :password_confirmation => password_confirmation)
        end
        
        # This method works in conjunction with attributes_to_save. See that method for a description of the why these methods exist.
        #
        # If the default behavior of this method is not sufficient for you because you have attr_protected or attr_accessible then
        # override this method and set them individually. Maybe something like this would be good:
        #
        #   attrs.each do |key, value|
        #     send("#{key}=", value)
        #   end
        def map_saved_attributes(attrs) # :doc:
          self.attributes = attrs
        end
        
        def validate_openid
          errors.add(:openid_identifier, "had the following error: #{@openid_error}") if @openid_error
        end
        
        def using_openid?
          respond_to?(:openid_identifier) && !openid_identifier.blank?
        end
        
        def openid_complete?
          session_class.controller.using_open_id? && session_class.controller.params[:for_model]
        end
        
        def authenticate_with_openid?
          session_class.activated? && ((using_openid? && openid_identifier_changed?) || openid_complete?)
        end
        
        def validate_password_with_openid?
          !using_openid? && require_password?
        end
    end
  end
end