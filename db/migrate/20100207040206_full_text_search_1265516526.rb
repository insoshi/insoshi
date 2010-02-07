class FullTextSearch1265516526 < ActiveRecord::Migration
  def self.up
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS people_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index people_fts_idx
        ON people
        USING gin((to_tsvector('english', coalesce(people.name, '') || ' ' || coalesce(people.description, ''))))

      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS categories_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index categories_fts_idx
        ON categories
        USING gin((to_tsvector('english', coalesce(categories.name, '') || ' ' || coalesce(categories.description, ''))))

      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS posts_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index posts_fts_idx
        ON posts
        USING gin((to_tsvector('english', coalesce(posts.body, ''))))

      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS groups_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index groups_fts_idx
        ON groups
        USING gin((to_tsvector('english', coalesce(groups.name, '') || ' ' || coalesce(groups.description, ''))))

      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS communications_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index communications_fts_idx
        ON communications
        USING gin((to_tsvector('english', coalesce(communications.subject, '') || ' ' || coalesce(communications.content, '') || ' ' || coalesce(communications.recipient_id, ''))))

      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS offers_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index offers_fts_idx
        ON offers
        USING gin((to_tsvector('english', coalesce(offers.name, '') || ' ' || coalesce(offers.description, ''))))

      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS people_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index people_fts_idx
        ON people
        USING gin((to_tsvector('english', coalesce(people.name, '') || ' ' || coalesce(people.description, ''))))

      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
        DROP index IF EXISTS reqs_fts_idx
      eosql
      ActiveRecord::Base.connection.execute(<<-'eosql')
                CREATE index reqs_fts_idx
        ON reqs
        USING gin((to_tsvector('english', coalesce(reqs.name, '') || ' ' || coalesce(reqs.description, ''))))

      eosql
  end
end
