module ActiveScaffold::Config
  class Base
    include ActiveScaffold::Configurable
    extend ActiveScaffold::Configurable

    def self.inherited(subclass)
      class << subclass
        # the crud type of the action. possible values are :create, :read, :update, :destroy, and nil.
        # this is not a setting for the developer. it's self-description for the actions.
        def crud_type; @crud_type; end

        protected

        def crud_type=(val)
          raise ArgumentError, "unknown CRUD type #{val}" unless [:create, :read, :update, :destroy].include?(val.to_sym)
          @crud_type = val.to_sym
        end
      end
    end
    # delegate
    def crud_type; self.class.crud_type end

    # the user property gets set to the instantiation of the local UserSettings class during the automatic instantiation of this class.
    attr_accessor :user

    class UserSettings
      def initialize(conf, storage, params)
        # the session hash relevant to this action
        @session = storage
        # all the request params
        @params = params
        # the configuration object for this action
        @conf = conf
      end
    end
  end
end