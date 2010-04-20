module ActiveScaffold::Config
  class Nested < Base
    self.crud_type = :read

    def initialize(core_config)
      @core = core_config
      self.shallow_delete = self.class.shallow_delete
    end

    # global level configuration
    # --------------------------
    cattr_accessor :shallow_delete
    @@shallow_delete = false

    # instance-level configuration
    # ----------------------------
    attr_accessor :shallow_delete

    # Add a nested ActionLink
    def add_link(label, models, options = {})
      options.reverse_merge! :security_method => :nested_authorized?, :position => :after
      options.merge! :label => label, :type => :member, :parameters => {:associations => models.join(' ')}
      options[:html_options] ||= {}
      options[:html_options][:class] = [options[:html_options][:class], models.join(' ')].compact.join(' ')
      @core.action_links.add('nested', options)
    end

    # the label for this Nested action. used for the header.
    attr_writer :label
    def label
      @label ? as_(@label) : as_(:add_existing_model, :model => @core.label)
    end

  end
end
