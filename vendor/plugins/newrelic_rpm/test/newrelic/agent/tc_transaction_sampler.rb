require 'newrelic/agent/transaction_sampler'
require 'newrelic/agent/mock_agent'
require 'test/unit'

::RPM_DEVELOPER = true unless defined? ::RPM_DEVELOPER

module NewRelic 
  module Agent
    
    class TransactionSampler
      public :with_builder
    end
    
    class TransationSamplerTests < Test::Unit::TestCase
      
      def test_multiple_samples
        @sampler = TransactionSampler.new(Agent.instance)
      
        run_sample_trace
        run_sample_trace
        run_sample_trace
        run_sample_trace
      
        samples = @sampler.get_samples
        assert_equal 4, samples.length
        assert_equal "a", samples.first.root_segment.called_segments[0].metric_name
        assert_equal "a", samples.last.root_segment.called_segments[0].metric_name
      end
      
      
      def test_harvest_slowest
        @sampler = TransactionSampler.new(Agent.instance)
        
        run_sample_trace
        run_sample_trace
        run_sample_trace { sleep 0.5 }
        run_sample_trace
        run_sample_trace
        
        slowest = @sampler.harvest_slowest_sample(nil)
        assert slowest.duration >= 0.5
        
        run_sample_trace { sleep 0.2 }
        not_as_slow = @sampler.harvest_slowest_sample(slowest)
        assert not_as_slow == slowest
        
        run_sample_trace { sleep 0.6 }
        new_slowest = @sampler.harvest_slowest_sample(slowest)
        assert new_slowest != slowest
        assert new_slowest.duration >= 0.6
      end
      
      
      def test_preare_to_send
        @sampler = TransactionSampler.new(Agent.instance)

        run_sample_trace { sleep 0.2 }
        sample = @sampler.harvest_slowest_sample(nil)
        
        ready_to_send = sample.prepare_to_send
        assert sample.duration == ready_to_send.duration
      end
      
      def test_multithread
        @sampler = TransactionSampler.new(Agent.instance)
        threads = []
        
        20.times do
          t = Thread.new(@sampler) do |the_sampler|
            @sampler = the_sampler
            100.times do
              run_sample_trace { sleep 0.01 }
            end
          end
          
          threads << t
        end
        threads.each {|t| t.join }
      end
      
      def test_sample_with_parallel_paths
        @sampler = TransactionSampler.new(Agent.instance)
        
        assert_equal 0, @sampler.scope_depth

        @sampler.notice_first_scope_push
        @sampler.notice_transaction "/path", nil, {}
        @sampler.notice_push_scope "a"
        
        assert_equal 1, @sampler.scope_depth 
        
        @sampler.notice_pop_scope "a"
        @sampler.notice_scope_empty

        assert_equal 0, @sampler.scope_depth 
        
        @sampler.notice_first_scope_push
        @sampler.notice_transaction "/path", nil, {}
        @sampler.notice_push_scope "a"
        @sampler.notice_pop_scope "a"
        @sampler.notice_scope_empty
      end
      
      def test_double_scope_stack_empty
        @sampler = TransactionSampler.new(Agent.instance)
        
        @sampler.notice_first_scope_push
        @sampler.notice_transaction "/path", nil, {}
        @sampler.notice_push_scope "a"
        @sampler.notice_pop_scope "a"
        @sampler.notice_scope_empty
        @sampler.notice_scope_empty
        @sampler.notice_scope_empty
        @sampler.notice_scope_empty
        
        assert_not_nil @sampler.harvest_slowest_sample(nil)
      end
      

      def test_record_sql_off
        sampler = TransactionSampler.new(Agent.instance, :record_sql => :off)
        
        sampler.notice_first_scope_push
        
        sampler.notice_sql("test", nil)
        
        segment = nil
        
        sampler.with_builder do |builder|
          segment = builder.current_segment
        end
        
        assert_nil segment[:sql]
      end

      def test_record_sql_raw
        sampler = TransactionSampler.new(Agent.instance, :record_sql => :raw)
        
        sampler.notice_first_scope_push
        
        sampler.notice_sql("test", nil)
        
        segment = nil
        
        sampler.with_builder do |builder|
          segment = builder.current_segment
        end
        
        assert segment[:sql]
      end

      def test_record_sql_raw
        sampler = TransactionSampler.new(Agent.instance, :record_sql => :obfuscated)
        
        sampler.notice_first_scope_push
        
        sampler.notice_sql("test", nil)
        
        segment = nil
        
        sampler.with_builder do |builder|
          segment = builder.current_segment
        end
        
        assert segment[:sql]
      end
      
      def test_big_sql
        @sampler = TransactionSampler.new(Agent.instance)
        
        @sampler.notice_first_scope_push
        
        sql = "SADJKHASDHASD KAJSDH ASKDH ASKDHASDK JASHD KASJDH ASKDJHSAKDJHAS DKJHSADKJSAH DKJASHD SAKJDH SAKDJHS"
        
        len = 0
        while len <= NewRelic::Agent::TransactionSampler::MAX_SQL_LENGTH
          @sampler.notice_sql(sql, nil)
          len += sql.length
        end
        
        segment = nil
        @sampler.with_builder do |builder|
          segment = builder.current_segment
        end
        
        sql = segment[:sql]
        
        assert sql.length <= NewRelic::Agent::TransactionSampler::MAX_SQL_LENGTH
      end
      
      
      def test_segment_obfuscated
        @sampler = TransactionSampler.new(Agent.instance)
        
        @sampler.notice_first_scope_push
        
        orig_sql = "SELECT * from Jim where id=66"
        
        @sampler.notice_sql(orig_sql, nil)
        
        segment = nil
        @sampler.with_builder do |builder|
          segment = builder.current_segment
        end
        
        assert_equal orig_sql, segment[:sql]
        assert_equal "SELECT * from Jim where id=?", segment.obfuscated_sql
      end
      
      def test_sql_normalization
        t = TransactionSampler.new(Agent.instance)
        
        # basic statement
        assert_equal "INSERT INTO X values(?,?, ? , ?)", 
                     t.default_sql_obfuscator("INSERT INTO X values('test',0, 1 , 2)")
                  
        # escaped literals
        assert_equal "INSERT INTO X values(?, ?,?, ? , ?)", 
                     t.default_sql_obfuscator("INSERT INTO X values('', 'jim''s ssn',0, 1 , 'jim''s son''s son')")
        
        # multiple string literals             
        assert_equal "INSERT INTO X values(?,?,?, ? , ?)", 
                     t.default_sql_obfuscator("INSERT INTO X values('jim''s ssn','x',0, 1 , 2)")
                     
        # empty string literal
        # NOTE: the empty string literal resolves to empty string, which for our purposes is acceptable
        assert_equal "INSERT INTO X values(?,?,?, ? , ?)", 
                     t.default_sql_obfuscator("INSERT INTO X values('','x',0, 1 , 2)")

        # try a select statement             
        assert_equal "select * from table where name=? and ssn=?",
                     t.default_sql_obfuscator("select * from table where name='jim gochee' and ssn=0012211223")
                     
        # number literals embedded in sql - oh well
        assert_equal "select * from table_? where name=? and ssn=?",
                     t.default_sql_obfuscator("select * from table_007 where name='jim gochee' and ssn=0012211223")
      end
      
      def test_sql_obfuscation_filters
        orig =  NewRelic::Agent.agent.obfuscator
        
        NewRelic::Agent.set_sql_obfuscator(:replace) do |sql|
          sql = "1" + sql
        end
        
        sql = "SELECT * FROM TABLE 123 'jim'"
        
        assert_equal "1" + sql, NewRelic::Agent.instance.obfuscator.call(sql)
        
        NewRelic::Agent.set_sql_obfuscator(:before) do |sql|
          sql = "2" + sql
        end

        assert_equal "12" + sql, NewRelic::Agent.instance.obfuscator.call(sql)

        NewRelic::Agent.set_sql_obfuscator(:after) do |sql|
          sql = sql + "3"
        end

        assert_equal "12" + sql + "3", NewRelic::Agent.instance.obfuscator.call(sql)
        
        NewRelic::Agent.agent.set_sql_obfuscator(:replace, &orig)
      end
      
      
    private      
      def run_sample_trace(&proc)
        @sampler.notice_first_scope_push
        @sampler.notice_transaction '/path', nil, {}
        @sampler.notice_push_scope "a"
        @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'wheat'", nil)
        @sampler.notice_push_scope "ab"
        @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'white'", nil)
        proc.call if proc
        @sampler.notice_pop_scope "ab"
        @sampler.notice_push_scope "lew"
        @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'french'", nil)
        @sampler.notice_pop_scope "lew"
        @sampler.notice_pop_scope "a"
        @sampler.notice_scope_empty
      end
      
    end
  end
end

