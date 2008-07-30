# REVIEW This is a monkey patch to inject the developer tool route into the
# parent app without requiring users to modify their routes. Of course this 
# has the effect of adding a route indiscriminately which is frowned upon by 
# some: http://www.ruby-forum.com/topic/126316#563328
module ActionController
  module Routing
    class RouteSet
      def draw
        clear!
        map = Mapper.new(self)
        map.named_route 'newrelic_developer', '/newrelic/:action/:id', :controller => 'newrelic' unless ::NR_CONFIG_FILE['skip_developer_route']
        
        yield map

        # 2.0 rails draw method is just slightly different...
        if Rails::VERSION::STRING.to_f >= 2.0
          install_helpers                 
        else
          named_routes.install          
        end
      end      
    end
  end
end