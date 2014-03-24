class SystemMessageTemplate < ActiveRecord::Base
  attr_accessible :text
  attr_accessible :title
  attr_accessible :message_type
  attr_accessible :lang
  attr_accessible *attribute_names, :as => :admin

  validates_presence_of :message_type
  validates :title, :presence => true, :if => :has_title_vars?
  validates :text, :presence => true, :if => :has_text_vars?
  validates_uniqueness_of :message_type

  TITLE_VARS = [ '{{estimated_hours}}', '{{req_name}}', '{{amount}}', '{{group_unit}}', '{{metadata_name}}' ]
  TEXT_VARS = [ '{{request_url}}', '{{customer_name}}', '{{amount}}', '{{group_unit}}' ]

  def trigger_offered_subject estimated_hours, req_name
    Mustache.render(self.title, :estimated_hours => estimated_hours, :req_name => req_name)
  end

  def trigger_subject request_name
    Mustache.render(self.title, :req_name => request_name)
  end

  def trigger_content request_url
    Mustache.render(self.text, :request_url => request_url)
  end

  def payment_notification_subject amount, group_unit, metadata_name
    Mustache.render(
      self.title,
      :amount => amount,
      :group_unit => group_unit,
      :metadata_name => metadata_name
    )
  end

  def payment_notification_text customer_name, amount, group_unit
    Mustache.render(
      self.text,
      :customer_name => customer_name,
      :amount => amount,
      :group_unit => group_unit
    )
  end

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