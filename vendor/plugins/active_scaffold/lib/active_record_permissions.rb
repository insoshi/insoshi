# This module attempts to create permissions conventions for your ActiveRecord models. It supports english-based
# methods that let you restrict access per-model, per-record, per-column, per-action, and per-user. All at once.
#
# You may define instance methods in the following formats:
#  def #{column}_authorized_for_#{action}?
#  def #{column}_authorized?
#  def authorized_for_#{action}?
#
# Your methods should allow for the following special cases:
#   * cron scripts
#   * guest users (or nil current_user objects)
module ActiveRecordPermissions
  # ActiveRecordPermissions needs to know what method on your ApplicationController will return the current user,
  # if available. This defaults to the :current_user method. You may configure this in your environment.rb if you
  # have a different setup.
  def self.current_user_method=(v); @@current_user_method = v; end
  def self.current_user_method; @@current_user_method; end
  @@current_user_method = :current_user

  # Whether the default permission is permissive or not
  # If set to true, then everything's allowed until configured otherwise
  def self.default_permission=(v); @@default_permission = v; end
  def self.default_permission; @@default_permission; end
  @@default_permission = true

  # This is a module aimed at making the current_user available to ActiveRecord models for permissions.
  module ModelUserAccess
    module Controller
      def self.included(base)
        base.prepend_before_filter :assign_current_user_to_models
      end

      # We need to give the ActiveRecord classes a handle to the current user. We don't want to just pass the object,
      # because the object may change (someone may log in or out). So we give ActiveRecord a proc that ties to the
      # current_user_method on this ApplicationController.
      def assign_current_user_to_models
        ActiveRecord::Base.current_user_proc = proc {send(ActiveRecordPermissions.current_user_method)}
      end
    end

    module Model
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # The proc to call that retrieves the current_user from the ApplicationController.
        attr_accessor :current_user_proc

        # Class-level access to the current user
        def current_user
          ActiveRecord::Base.current_user_proc.call if ActiveRecord::Base.current_user_proc
        end
      end

      # Instance-level access to the current user
      def current_user
        self.class.current_user
      end
    end
  end

  module Permissions
    def self.included(base)
      base.extend SecurityMethods
      base.send :include, SecurityMethods
    end

    # Because any class-level queries get delegated to the instance level via a new record,
    # it's useful to know when the authorization query is meant for a specific record or not.
    # But using new_record? is confusing, even though accurate. So this is basically just a wrapper.
    def existing_record_check?
      !new_record?
    end

    module SecurityMethods
      # A generic authorization query. This is what will be called programatically, since
      # the actual permission methods can't be guaranteed to exist. And because we want to
      # intelligently combine multiple applicable methods.
      #
      # options[:crud_type] should be a CRUD verb (:create, :read, :update, :destroy)
      # options[:column] should be the name of a model attribute
      # options[:action] is the name of a method
      def authorized_for?(options = {})
        raise ArgumentError, "unknown crud type #{options[:crud_type]}" if options[:crud_type] and ![:create, :read, :update, :delete].include?(options[:crud_type])

        # column_authorized_for_crud_type? has the highest priority over other methods,
        # you can disable a crud verb and enable that verb for a column
        # (for example, disable update and enable inplace_edit in a column)
        method = column_and_crud_type_security_method(options[:column], options[:crud_type])
        return send(method) if method and respond_to?(method)

        # authorized_for_action? has higher priority than other methods,
        # you can disable a crud verb and enable an action with that crud verb
        # (for example, disable update and enable an action with update as crud type)
        method = action_security_method(options[:action])
        return send(method) if method and respond_to?(method)

        # collect other possibly-related methods that actually exist
        methods = [
          column_security_method(options[:column]),
          crud_type_security_method(options[:crud_type]),
        ].compact.select {|m| respond_to?(m)}

        # if any method returns false, then return false
        return false if methods.any? {|m| !send(m)}

        # if any method actually exists then it must've returned true, so return true
        return true unless methods.empty?

        # if no method exists, return the default permission
        return ActiveRecordPermissions.default_permission
      end

      private

      def column_security_method(column)
        "#{column}_authorized?" if column
      end

      def crud_type_security_method(crud_type)
        "authorized_for_#{crud_type}?" if crud_type
      end

      def action_security_method(action)
        "authorized_for_#{action}?" if action
      end

      def column_and_crud_type_security_method(column, crud_type)
        "#{column}_authorized_for_#{crud_type}?" if column and crud_type
      end
    end
  end
end
