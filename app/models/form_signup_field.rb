class FormSignupField < ActiveRecord::Base
  attr_accessible :field_type, :key, :mandatory, :order, :title, :options
  attr_accessible *attribute_names, :as => :admin
  has_many :person_metadata

  validates_presence_of :field_type, :key, :order, :title
  validates_inclusion_of :field_type,
    :in => %w(text_field text_area collection_select),
    :message => "%s is not included in the list"
  validates_uniqueness_of :key

  scope :all_with_order, -> { order("form_signup_fields.order ASC").all }

  before_update :change_order

  def get_options_for_dropdown
    self.options.split(",").map { |s| s.gsub(/\s/,'') }
  end

  def get_field_with_field_type field_type
    self.find_by field_type: field_type
  end

  private
    def change_order
      # ActiveRecord::Base.transaction do
      #   binding.pry
      #   field_to_change = FormSignupField.where(order: self.order).first
      #   field_to_change.order = self.order_was
      #   field_to_change.save
      # end
    end
end