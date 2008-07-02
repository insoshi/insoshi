require "#{File.dirname(__FILE__)}/abstract_note"

module Footnotes
  module Notes
    class QueriesNote < AbstractNote
      @@sql = []
      cattr_accessor :sql

      def self.start!
        @@sql = []
      end

      def self.to_sym
        :queries
      end

      def title
        "Queries (#{@@sql.length})"
      end

      def legend
        'Queries'
      end

      def stylesheet
        '.queries_debug_table thead, .queries_debug_table tbody {text-align: center; color:#FF0000;}'
      end

      def content
        html = ''
        @@sql.collect do |item|
          html << "<b>#{item[0].to_s.upcase}</b>\n"
          html << "#{item[1] || 'SQL'} (#{sprintf('%f',item[2])}s)\n"
          html << "#{item[3].gsub(/(\s)+/,' ').gsub('`','')}\n"
          html << (item[4] ? mount_table(item[4], :class => 'queries_debug_table') : "\n")
        end
        "<pre>#{html}</pre>"
      end
    end
  end

  module Extensions
    module QueryAnalyzer
      def self.parse_explain(results)
        table = []
        table << results.fetch_fields.map(&:name)
        results.each{|row| table << row}
        table
      end

      def self.included(base)
        base.class_eval do
          alias_method_chain :execute, :analyzer
        end
      end

      def execute_with_analyzer(sql, name = nil)
        query_results = nil
        time = Benchmark.realtime { query_results = execute_without_analyzer(sql, name) }

        if sql =~ /^(select)|(create)|(update)|(delete)\b/i
          operation = $&.downcase.to_sym
          explain = nil

          if adapter_name == 'MySQL' && operation == :select
            log_silence do
              explain = execute_without_analyzer("explain #{sql}", name)
            end
            explain = Footnotes::Extensions::QueryAnalyzer.parse_explain(explain)
          end
          Footnotes::Notes::QueriesNote.sql << [operation, name, time, sql, explain]
        end

        query_results
      end
    end

    module AbstractAdapter
      def log_silence
        result = nil
        if @logger
          @logger.silence do
            result = yield
          end        
        else
          result = yield
        end
        result
      end
    end
  end
end

if Footnotes::Notes::QueriesNote.included?
  ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Footnotes::Extensions::AbstractAdapter
  ActiveRecord::ConnectionAdapters.local_constants.each do |adapter|
    next unless adapter =~ /.*[^Abstract]Adapter$/
    next if adapter =~ /SQLite.Adapter$/
    eval("ActiveRecord::ConnectionAdapters::#{adapter}").send :include, Footnotes::Extensions::QueryAnalyzer
  end
end