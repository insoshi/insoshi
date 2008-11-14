class ModelStub < ActiveRecord::Base
  abstract_class = true
  has_one :other_model, :class_name => 'ModelStub'
  has_many :other_models, :class_name => 'ModelStub'
  
  cattr_accessor :stubbed_columns
  self.stubbed_columns = [:a, :b, :c, :d, :id]
  attr_accessor *self.stubbed_columns

  def other_model=(val)
    @other_model = val
  end
  def other_model
    @other_model || nil
  end

  def other_models=(val)
    @other_models = val
  end
  def other_models
    @other_models || []
  end

  def self.columns
    @columns ||= self.stubbed_columns.map{|c| ActiveRecord::ConnectionAdapters::Column.new(c.to_s, '') }
  end

  def self.columns_hash
    @columns_hash ||= columns.inject({}) { |hash, column| hash[column.name.to_s] = column; hash }
  end

  # column-level security methods, used for testing
  def self.a_authorized_for_bar?(user)
    true
  end
  def self.b_authorized?(user)
    false
  end
end
