class FormSignupField < ActiveRecord::Base
  attr_accessible :field_type, :key, :mandatory, :order, :title, :options
  attr_accessible *attribute_names, :as => :admin
  has_many :person_metadata

  validates_presence_of :field_type, :key, :order, :title
  validates_inclusion_of :field_type,
    :in => %w(text_field text_area collection_select),
    :message => "%s is not included in the list"
  validates_uniqueness_of :key, :title
  validates :options, :presence => true, :if => :collection_select?

  scope :all_with_order, -> { order("form_signup_fields.order ASC").all }

  def get_options_for_dropdown
    self.options.split(",").map { |s| s.gsub(/\s/,'') }
  end

  def get_field_with_field_type field_type
    self.find_by field_type: field_type
  end

  def collection_select?
    field_type == "collection_select"
  end
end