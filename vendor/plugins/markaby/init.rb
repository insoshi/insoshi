$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'markaby'
require 'markaby/rails'

ActionView::Base::register_template_handler 'mab', Markaby::Rails::ActionViewTemplateHandler

ActionController::Base.send :include, Markaby::Rails::ActionControllerHelpers
