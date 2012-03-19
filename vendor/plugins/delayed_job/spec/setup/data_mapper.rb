require 'dm-core'
require 'dm-validations'

require 'delayed/backend/data_mapper'

DataMapper.logger = Delayed::Worker.logger
DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.auto_migrate!