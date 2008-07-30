require 'newrelic/agent/error_collector'
require 'test/unit'

module NewRelic
  module Agent
    
    class ErrorCollectorTests < Test::Unit::TestCase
      
      def setup
        @error_collector = ErrorCollector.new(nil)
      end

      def test_simple
        @error_collector.notice_error('path', {:x => 'y'}, Exception.new("message"))
        
        old_errors = []
        errors = @error_collector.harvest_errors(old_errors)
        
        assert_equal errors.length, 1
        
        err = errors.first
        assert err.message == 'message'
        assert err.params[:x] == 'y'
        assert err.path == 'path'
        assert err.exception_class == 'Exception'
        
        # the collector should now return an empty array since nothing
        # has been added since its last harvest
        errors = @error_collector.harvest_errors(nil)
        assert errors.length == 0
      end
      
      def test_collect_failover
        @error_collector.notice_error('first', {:x => 'y'}, Exception.new("message"))
        
        errors = @error_collector.harvest_errors([])
        
        @error_collector.notice_error('path', {:x => 'y'}, Exception.new("message"))
        @error_collector.notice_error('path', {:x => 'y'}, Exception.new("message"))
        @error_collector.notice_error('path', {:x => 'y'}, Exception.new("message"))
        
        errors = @error_collector.harvest_errors(errors)
        
        assert errors.length == 4
        assert errors.first.path == 'first'
      end
      
      def test_queue_overflow
        max_q_length = 20     # for some reason I can't read the constant in ErrorCollector
        
        (max_q_length + 5).times do |n|
          @error_collector.notice_error("path", {:x => n}, Exception.new("exception #{n}"))
        end
        
        errors = @error_collector.harvest_errors([])
        assert errors.length == max_q_length 
        errors.each_index do |i|
          err = errors.shift
          assert_equal err.params[:x], i
        end
      end
    end
  end
end