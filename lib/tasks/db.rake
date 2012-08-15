namespace :db do
  desc "Create the full text indices"
  task :full_text_index => :environment do
    def drop_stmt(tbl)
      "DROP index IF EXISTS #{tbl}_fts_idx"
    end
    def create_stmt(tbl, *cols)
      c = cols.map {|col| "coalesce(#{tbl}.#{col}, '')"}.join(" || ' ' || ")
      "CREATE index #{tbl}_fts_idx ON #{tbl} USING gin((to_tsvector('english', #{c})))"
    end

    statements = %w"people categories groups offers reqs".inject([]) do |memo, tbl|
      memo << drop_stmt(tbl) << create_stmt(tbl, "name", "description")
    end << drop_stmt("posts") << create_stmt("posts", "body")

    statements.each &ActiveRecord::Base.connection.method(:execute)
  end
end
