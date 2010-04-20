require 'active_scaffold'

# TODO: clean up extensions. some could be organized for autoloading, and others could be removed entirely.
Dir["#{File.dirname __FILE__}/lib/extensions/*.rb"].each { |file| require file }

ActionController::Base.send(:include, ActiveScaffold)
ActionController::Base.send(:include, RespondsToParent)
ActionController::Base.send(:include, ActiveScaffold::Helpers::ControllerHelpers)
ActionView::Base.send(:include, ActiveScaffold::Helpers::ViewHelpers)

ActionController::Base.class_eval {include ActiveRecordPermissions::ModelUserAccess::Controller}
ActiveRecord::Base.class_eval     {include ActiveRecordPermissions::ModelUserAccess::Model}
ActiveRecord::Base.class_eval     {include ActiveRecordPermissions::Permissions}

require 'bridges/bridge.rb'

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'lib', 'active_scaffold', 'locale', '*.{rb,yml}')]
