##
## Add MIME type for JSON (backwards compat)
##
unless Mime.const_defined?(:JSON)
  # Rails 1.1 Method
  # Register a new Mime::Type
  Mime::JSON = Mime::Type.new 'application/json', :json, %w( text/json )
  Mime::LOOKUP["application/json"] = Mime::JSON
  Mime::LOOKUP["text/json"] = Mime::JSON

  # Its default handler in responder
  class ActionController::MimeResponds::Responder

    DEFAULT_BLOCKS[:json] = %q{
      Proc.new do
        render(:action => "#{action_name}.rjson", :content_type => Mime::JSON, :layout => false)
      end
    }

    for mime_type in %w( json )
      eval <<-EOT
        def #{mime_type}(&block)
           custom(Mime::#{mime_type.upcase}, &block)
        end
      EOT
    end
  end
end