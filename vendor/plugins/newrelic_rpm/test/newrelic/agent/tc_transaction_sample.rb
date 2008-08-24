require 'newrelic/agent/mock_ar_connection'
require 'newrelic/agent/testable_agent'
require 'newrelic/agent/transaction_sampler'
require 'newrelic/transaction_sample'
require 'test/unit'

::RPM_DEVELOPER = true unless defined? ::RPM_DEVELOPER


::SQL_STATEMENT = "SELECT * from sandwiches"



module NewRelic
    class TransationSampleTests < Test::Unit::TestCase
      
      def initialize(test)
        super(test)
        @traceoptions = {}
      end
      
      def test_sql
        assert ActiveRecord::Base.test_connection({}).disconnected == false

        t = get_sql_transaction(::SQL_STATEMENT, ::SQL_STATEMENT)
        
        s = t.prepare_to_send(:obfuscate_sql => true, :explain_enabled => true, :explain_sql => 0.00000001)
        
        explain_count = 0
        
        s.each_segment do |segment|
          
          if segment.params[:explanation]
            explanations = segment.params[:explanation]
            
            explanations.each do |explanation|
              assert_equal "EXPLAIN #{::SQL_STATEMENT}", explanation[0]
              explain_count += 1
            end
          end
        end
                
        assert_equal 2, explain_count
        assert ActiveRecord::Base.test_connection({}).disconnected
      end
      
      
      def test_disable_sql
        t = nil
        NewRelic::Agent.disable_sql_recording do
          t = get_sql_transaction(::SQL_STATEMENT, ::SQL_STATEMENT)
        end
        
        s = t.prepare_to_send(:obfuscate_sql => true, :explain_sql => 0.00000001)
        
        s.each_segment do |segment|
          fail if segment.params[:explanation] || segment.params[:obfuscated_sql]
        end        
      end
      
      
      def test_record_sql_off
        @traceoptions = {:record_sql => :off}
        
        t = get_sql_transaction(::SQL_STATEMENT, ::SQL_STATEMENT)
        
        s = t.prepare_to_send(:obfuscate_sql => true, :explain_sql => 0.00000001, :record_sql => :off)
        
        s.each_segment do |segment|
          fail if segment.params[:explanation] || segment.params[:obfuscated_sql] || segment.params[:sql]
        end        
      end

      
      def test_record_sql_raw
        @traceoptions = {:record_sql => :raw}
        
        t = get_sql_transaction(::SQL_STATEMENT, ::SQL_STATEMENT)
        
        s = t.prepare_to_send(:obfuscate_sql => true, :explain_sql => 0.00000001, :record_sql => :raw)
        
        got_one = false
        s.each_segment do |segment|
          fail if segment.params[:obfuscated_sql]
          got_one = got_one || segment.params[:explanation] || segment.params[:sql]
        end
        
        assert got_one
      end


      def test_record_sql_obfuscated
        @traceoptions = {:record_sql => :obfuscated}
        
        t = get_sql_transaction(::SQL_STATEMENT, ::SQL_STATEMENT)
        
        s = t.prepare_to_send(:obfuscate_sql => true, :explain_sql => 0.00000001, :record_sql => :obfuscated)
        
        got_one = false
        s.each_segment do |segment|
          fail if segment.params[:sql]
          got_one = got_one || segment.params[:explanation] || segment.params[:sql_obfuscated]
        end        
        
        assert got_one
      end

      
      def test_sql_throw
        ActiveRecord::Base.test_connection({}).throw = true

        t = get_sql_transaction(::SQL_STATEMENT, ::SQL_STATEMENT)
        
        # the sql connection will throw
        t.prepare_to_send(:obfuscate_sql => true, :explain_sql => 0.00000001)
      end
      
      def test_exclusive_duration
        t = NewRelic::TransactionSample.new
        
        t.params[:test] = "hi"
        t.begin_building
        
        s1 = t.create_segment(1, "controller")
        
        t.root_segment.add_called_segment(s1)
        
        s2 = t.create_segment(2, "AR1")
        
        s2.params[:test] = "test"
        
        s2.to_s
        
        s1.add_called_segment(s2)
        
        s2.end_trace 3
        s1.end_trace 4
        
        t.to_s
        
        assert_equal 3.0, s1.duration
        assert_equal 2.0, s1.exclusive_duration
      end
      
      
      
      private
        def get_sql_transaction(*sql)
          sampler = NewRelic::Agent::TransactionSampler.new(NewRelic::Agent.instance, @traceoptions)
          sampler.notice_first_scope_push
          sampler.notice_transaction '/path', nil, :jim => "cool"
          sampler.notice_push_scope "a"
          
          sampler.notice_transaction '/path/2', nil, :jim => "cool"

          sql.each {|sql_statement| sampler.notice_sql(sql_statement, {:adapter => "test"} ) }
          
          sleep 1.0
          
          sampler.notice_pop_scope "a"
          sampler.notice_scope_empty
          
          sampler.get_samples[0]
        end
      
      
    end
end
