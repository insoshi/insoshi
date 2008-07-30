require 'newrelic/agent/worker_loop'
require 'test/unit'

module NewRelic::Agent
  class WorkerLoop
    public :run_next_task
  end
  
  class WorkerLoopTests < Test::Unit::TestCase
    def setup
      @worker_loop = WorkerLoop.new
      @test_start_time = Time.now
    end
    
    def test_add_task
      @x = false
      period = 1.0
      @worker_loop.add_task(period) do
        @x = true
      end

      assert !@x
      @worker_loop.run_next_task
      assert @x
      check_test_timestamp period
    end
    
    def test_add_tasks_with_different_periods
      @last_executed = nil
      
      period1 = 0.2
      period2 = 0.35
      
      @worker_loop.add_task(period1) do
        @last_executed = 1
      end
      
      @worker_loop.add_task(period2) do
        @last_executed = 2
      end
      
      @worker_loop.run_next_task
      assert_equal @last_executed, 1      # 0.2 s
      check_test_timestamp(0.2)
      
      @worker_loop.run_next_task
      assert_equal @last_executed, 2      # 0.35 s
      check_test_timestamp(0.35)
    
      @worker_loop.run_next_task
      assert_equal @last_executed, 1      # 0.4 s
      check_test_timestamp(0.4)
      
      @worker_loop.run_next_task
      assert_equal @last_executed, 1      # 0.6 s
      check_test_timestamp(0.6)

      @worker_loop.run_next_task
      assert_equal @last_executed, 2      # 0.7 s
      check_test_timestamp(0.7)
    end

    private
      def check_test_timestamp(expected)
        ts = Time.now - @test_start_time
        delta = (expected - ts).abs
        assert(delta < 0.05, "#{delta} exceeds 50 milliseconds")
      end
  end
end
