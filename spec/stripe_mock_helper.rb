module StripeMock
  module RequestHandlers
    module Plans
      def get_plan(route, method_url, params, headers)
        # Added line - prevents failing encoding of method_url so it finds stripe plans properly.
        method_url = URI.decode(method_url).gsub("+", " ")
        route =~ method_url
        assert_existance :plan, $1, plans[$1]
        plans[$1] ||= Data.mock_plan(:id => $1)
      end
      def delete_plan(route, method_url, params, headers)
        # Added line - prevents failing encoding of method_url so it finds stripe plans properly.
        method_url = URI.decode(method_url).gsub("+", " ")
        route =~ method_url
        assert_existance :plan, $1, plans[$1]
        plans.delete($1)
      end
    end
  end
end