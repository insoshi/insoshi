require 'mongo_mapper'

MongoMapper.config = {
  RAILS_ENV => {'database' => 'delayed_job'}
}
MongoMapper.connect RAILS_ENV

unless defined?(Story)
  class Story
    include ::MongoMapper::Document
    def tell; text; end       
    def whatever(n, _); tell*n; end
    def self.count; end
  
    handle_asynchronously :whatever
  end
end
