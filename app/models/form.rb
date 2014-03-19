class Form < ActiveRecord::Base
  attr_accessible :text
  attr_accessible :title
  attr_accessible :message_type
  attr_accessible :lang
  attr_accessible *attribute_names, :as => :admin

  validates_presence_of :message_type
  validates :title, :presence => true, :if => :has_title_vars?
  validates :text, :presence => true, :if => :has_text_vars?

  TITLE_VARS = [ '{{estimated_hours}}', '{{req_name}}', '{{amount}}', '{{group_unit}}', '{{metadata_name}}' ]
  TEXT_VARS = [ '{{request_url}}', '{{customer_name}}', '{{amount}}', '{{group_unit}}' ]

  def self.with_type_and_language type, lang
    self.where(:message_type => type.to_s, :lang => lang.to_s).first!
  end

  def has_type type
    self.message_type == type ? true : false
  end

  private
    def has_title_vars?
      TITLE_VARS.each do |var|
        if self.title.include? var.to_s 
          return true
        end
      end
      return false
    end


    def has_text_vars?
      TEXT_VARS.each do |var|
        if self.text.include? var.to_s 
          return true
        end
      end
      if self.has_type 'offered'
        return true
      else
        return false
      end
    end
end