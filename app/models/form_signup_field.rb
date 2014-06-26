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

  scope :all_with_order, -> { order('"order" ASC') }

  def get_options_for_dropdown
    self.options.split(",").map { |s| s.gsub(/\s/,'') }
  end

  def get_field_with_field_type field_type
    self.find_by field_type: field_type
  end

  def collection_select?
    field_type == "collection_select"
  end


  rails_admin do
    label "Signup field"
    label_plural "Signup fields"

    list do
      field :title
      field :field_type
      field :mandatory
      field :order
    end

    edit do
      field :title
      field :key
      field :field_type do
        properties[:collection] = [
          ['Single line text input', 'text_field'],
          ['Paragraph text input', 'text_area'],
          ['Dropdown choice', 'collection_select']
        ]
        partial "select"
      end
      field :options do
        help 'Required - only when "Dropdown choice" is selected'
      end
      field :mandatory
      field :order do
        properties[:collection] = 1..(FormSignupField.count + 1)
        partial "select"
      end
    end
  end
end