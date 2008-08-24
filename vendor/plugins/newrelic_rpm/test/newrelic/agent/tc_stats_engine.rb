require 'test/unit'
require 'newrelic/agent/stats_engine'
require File.join(File.dirname(__FILE__),'mock_agent')


module NewRelic::Agent
  class StatsEngineTests < Test::Unit::TestCase
    def setup
      @engine = StatsEngine.new
    end
  
    def test_get_no_scope
      s1 = @engine.get_stats "a"
      s2 = @engine.get_stats "a"
      s3 = @engine.get_stats "b"
      
      assert_not_nil s1
      assert_not_nil s2
      assert_not_nil s3
      
      assert s1 == s2
      assert s1 != s3
    end
    
    def test_harvest
      s1 = @engine.get_stats "a"
      s2 = @engine.get_stats "c"
      
      s1.trace_call 10
      s2.trace_call 1
      s2.trace_call 3
      
      assert @engine.get_stats("a").call_count == 1
      assert @engine.get_stats("a").total_call_time == 10
      
      assert @engine.get_stats("c").call_count == 2
      assert @engine.get_stats("c").total_call_time == 4
      
      metric_data = @engine.harvest_timeslice_data({}, {}).values
      
      # after harvest, all the metrics should be reset
      assert @engine.get_stats("a").call_count == 0
      assert @engine.get_stats("a").total_call_time == 0
      
      assert @engine.get_stats("c").call_count == 0
      assert @engine.get_stats("c").total_call_time == 0

      metric_data = metric_data.reverse if metric_data[0].metric_spec.name != "a"

      assert metric_data[0].metric_spec.name == "a"

      assert metric_data[0].stats.call_count == 1
      assert metric_data[0].stats.total_call_time == 10
    end
    
    def test_harvest_with_merge
      s = @engine.get_stats "a"
      s.trace_call 1
      
      assert @engine.get_stats("a").call_count == 1
      
      harvest = @engine.harvest_timeslice_data({}, {})
      assert s.call_count == 0
      s.trace_call 2
      assert s.call_count == 1
      
      # this calk should merge the contents of the previous harvest,
      # so the stats for metric "a" should have 2 data points
      harvest = @engine.harvest_timeslice_data(harvest, {})
      stats = harvest.fetch(NewRelic::MetricSpec.new("a")).stats
      assert stats.call_count == 2
      assert stats.total_call_time == 3
    end
    
    def test_scope
      @engine.push_scope "scope1"
      assert @engine.peek_scope.name == "scope1"
      
      expected = @engine.push_scope "scope2"
      @engine.pop_scope expected
      
      scoped = @engine.get_stats "a"
      scoped.trace_call 3
      
      assert scoped.total_call_time == 3
      unscoped = @engine.get_stats "a"
      
      assert scoped == @engine.get_stats("a")
      assert unscoped.total_call_time == 3
    end
   

    def test_simplethrowcase(depth=0)
      
      fail "doh" if depth == 10
      
      scope = @engine.push_scope "scope#{depth}"    
            
      begin
        test_simplethrowcase(depth+1)
      rescue StandardError => e
        if (depth != 0)
          raise e
        end
      ensure
        @engine.pop_scope scope
      end
      
      if depth == 0
        assert @engine.peek_scope.nil?
      end
    end
    
    
    def test_scope_failure
      scope1 = @engine.push_scope "scope1"
      @engine.push_scope "scope2"
      
      begin
        @engine.pop_scope scope1
        fail "Didn't throw when scope push/pop mismatched"
      rescue
        # success
      end
    end
    
    def test_children_time
      t1 = Time.now
      
      expected1 = @engine.push_scope "a"
        sleep 0.1
        t2 = Time.now

        expected2 = @engine.push_scope "b"
          sleep 0.2
          t3 = Time.now
          
          expected = @engine.push_scope "c"
            sleep 0.3
          scope = @engine.pop_scope expected
          
          t4 = Time.now
    
          check_time_approximate 0, scope.children_time
          check_time_approximate 0.3, @engine.peek_scope.children_time
    
          sleep 0.1
          t5 = Time.now
    
          expected = @engine.push_scope "d"
            sleep 0.2
          scope = @engine.pop_scope expected
          
          t6 = Time.now

          check_time_approximate 0, scope.children_time
    
        scope = @engine.pop_scope expected2
        assert_equal scope.name, 'b'
        
        check_time_approximate (t4 - t3) + (t6 - t5), scope.children_time
      
      scope = @engine.pop_scope expected1
      assert_equal scope.name, 'a'
      
      check_time_approximate (t6 - t2), scope.children_time
    end
    
    def test_simple_start_transaction
      @engine.push_scope "scope"
      @engine.start_transaction
      assert @engine.peek_scope.nil?
    end 
    
    
    # test for when the scope stack contains an element only used for tts and not metrics
    def test_simple_tt_only_scope
       scope1 = @engine.push_scope "a", 0, true
       scope2 = @engine.push_scope "b", 10, false
       scope3 = @engine.push_scope "c", 20, true
       
       @engine.pop_scope scope3, 10
       @engine.pop_scope scope2, 10
       @engine.pop_scope scope1, 10
       
       assert_equal 0, scope3.children_time
       assert_equal 10, scope2.children_time
       assert_equal 10, scope1.children_time 
    end
    
    def test_double_tt_only_scope
       scope1 = @engine.push_scope "a", 0, true
       scope2 = @engine.push_scope "b", 10, false
       scope3 = @engine.push_scope "c", 20, false
       scope4 = @engine.push_scope "d", 30, true
       
       @engine.pop_scope scope4, 10
       @engine.pop_scope scope3, 10
       @engine.pop_scope scope2, 10
       @engine.pop_scope scope1, 10
       
       assert_equal 0, scope4.children_time
       assert_equal 10, scope3.children_time
       assert_equal 10, scope2.children_time
       assert_equal 10, scope1.children_time 
    end
    

    private 
      def check_time_approximate(expected, actual)
        assert((expected - actual).abs < 0.01, "Expected #{expected}, got #{actual}")
      end

  end
  

  
end
