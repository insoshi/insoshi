module ActiveScaffold::DataStructures
  class ActionLink
    # provides a quick way to set any property of the object from a hash
    def initialize(action, options = {})
      # set defaults
      self.action = action.to_s
      self.label = action
      self.confirm = false
      self.type = :collection
      self.inline = true
      self.method = :get
      self.crud_type = :delete if [:destroy].include?(action.to_sym)
      self.crud_type = :create if [:create, :new].include?(action.to_sym)
      self.crud_type = :update if [:edit, :update].include?(action.to_sym)
      self.crud_type ||= :read
      self.parameters = {}
      self.html_options = {}

      # apply quick properties
      options.each_pair do |k, v|
        setter = "#{k}="
        self.send(setter, v) if self.respond_to? setter
      end
    end

    # the action-path for this link. what page to request? this is required!
    attr_accessor :action
    
    # the controller for this action link. if nil, the current controller should be assumed.
    attr_accessor :controller

    # a hash of request parameters
    attr_accessor :parameters

    # the RESTful method
    attr_accessor :method

    # what string to use to represent this action
    attr_writer :label
    def label
      @label.is_a?(Symbol) ? as_(@label) : @label
    end

    # if the action requires confirmation
    attr_writer :confirm
    def confirm(label = '')
      @confirm.is_a?(String) ? @confirm : as_(@confirm, :label => label)
    end
    def confirm?
      @confirm ? true : false
    end
    
    # if the action uses a DHTML based (i.e. 2-phase) confirmation
    attr_writer :dhtml_confirm
    def dhtml_confirm
      @dhtml_confirm
    end
    def dhtml_confirm?
      @dhtml_confirm
    end

    # what method to call on the controller to see if this action_link should be visible
    # note that this is only the UI part of the security. to prevent URL hax0rz, you also need security on requests (e.g. don't execute update method unless authorized).
    attr_writer :security_method
    def security_method
      @security_method || "#{self.action}_authorized?"
    end

    def security_method_set?
      !!@security_method
    end

    # the crud type of the (eventual?) action. different than :method, because this crud action may not be imminent.
    # this is used to determine record-level authorization (e.g. record.authorized_for?(:crud_type => link.crud_type).
    # options are :create, :read, :update, and :delete
    attr_accessor :crud_type

    # an "inline" link is inserted into the existing page
    # exclusive with popup? and page?
    def inline=(val)
      @inline = (val == true)
      self.popup = self.page = false if @inline
    end
    def inline?; @inline end

    # a "popup" link displays in a separate (browser?) window. this will eventually take arguments.
    # exclusive with inline? and page?
    def popup=(val)
      @popup = (val == true)
      if @popup
        self.inline = self.page = false

        # the :method parameter doesn't mix with the :popup parameter
        # when/if we start using DHTML popups, we can bring :method back
        self.method = nil
      end
    end
    def popup?; @popup end

    # a "page" link displays by reloading the current page
    # exclusive with inline? and popup?
    def page=(val)
      @page = (val == true)
      if @page
        self.inline = self.popup = false

        # when :method is defined, ActionView adds an onclick to use a form ...
        # so it's best to just empty out :method whenever possible.
        # we only ever need to know @method = :get for things that default to POST.
        # the only things that default to POST are forms and ajax calls.
        # when @page = true, we don't use ajax.
        self.method = nil if method == :get
      end
    end
    def page?; @page end

    # where the result of this action should insert in the display.
    # for :type => :collection, supported values are:
    #   :top
    #   :bottom
    #   :replace (for updating the entire table)
    #   false (no attempt at positioning)
    # for :type => :member, supported values are:
    #   :before
    #   :replace
    #   :after
    #   false (no attempt at positioning)
    attr_writer :position
    def position
      return @position unless @position.nil? or @position == true
      return :replace if self.type == :member
      return :top if self.type == :collection
      raise "what should the default position be for #{self.type}?"
    end

    # what type of link this is. currently supported values are :collection and :member.
    attr_accessor :type

    # html options for the link
    attr_accessor :html_options
  end
end
