


module ActionView::Helpers::ActiveRecordHelper


  
  # Returns a string with a div containing all of the error messages for the object and method located as instance variables by the names
  # given.  This method mimics the output of +error_messages_for+, and is meant to be used in leau of +error_message_on+.
  #
  # This div can be tailored by the following options:
  #
  # * <tt>id</tt> - The id of the error div (default: errorExplanation)
  # * <tt>class</tt> - The class of the error div (default: errorExplanation)
  # * <tt>method_name</tt> - The object name to use in the header, or
  # any text that you prefer. If <tt>method_name</tt> is not set, the name of
  # the method will be used.
  #
  # Specifying one object:
  # 
  #   error_messages_on 'user', 'login'
  #
  #
  # NOTE: This is a pre-packaged presentation of the errors with embedded strings and a certain HTML structure. If what
  # you need is significantly different from the default presentation, it makes plenty of sense to access the object.errors
  # instance yourself and set it up. View the source of this method to see how easy it is.
  def error_messages_on(object, method, options = {})
    html = {}
    options.stringify_keys!
    ['id', 'class'].each do |key|
      if options.include?(key)
        value = options[key]
        html[key] = value unless value.blank?
      else
        html[key] = 'errorExplanation'
      end
    end
    name = options['method_name'] ||= method.to_s.humanize.capitalize
    if (obj = instance_variable_get("@#{object}")) && (errors = obj.errors.on(method))
      [errors].flatten!
    content_tag(:div,
      content_tag(:ul, errors.map {|msg| content_tag(:li, "#{name} #{msg}") }),
      html
    )
    else 
      ''
    end
  end
  
  
  
  def errors_to_s(errors)
    errors.map do |e, m|
      "#{e.humanize unless e == "base"} #{m}\n"
    end.to_s.chomp
  end
  
  
end