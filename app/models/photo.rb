# == Schema Information
#
# Table name: photos
#
#  id             :integer          not null, primary key
#  parent_id      :integer
#  content_type   :string(255)
#  thumbnail      :string(255)
#  size           :integer
#  width          :integer
#  height         :integer
#  primary        :boolean
#  created_at     :datetime
#  updated_at     :datetime
#  picture        :string(255)
#  photoable_id   :integer
#  photoable_type :string(255)
#  picture_for    :string(255)
#  highres        :boolean          default(TRUE)
#

class Photo < ActiveRecord::Base
  include ActivityLogger
  UPLOAD_LIMIT = 5 # megabytes
  
  belongs_to :photoable, :polymorphic => true

  attr_accessible :picture, :primary, :photoable, :picture_for

  has_many :activities, :as => :item, :dependent => :destroy

  before_save :update_photo_attributes
  after_save :log_activity

  mount_uploader :picture, ImageUploader
  
  def log_activity
    if self.primary?
      unless (self.photoable.nil? || self.photoable.class != Person)
        activity = Activity.create!(:item => self, :person => self.photoable)
        add_activities(:activity => activity, :person => self.photoable)
      end
    end
  end

  def update_photo_attributes
    if picture.present? && picture_changed?
      self.content_type = picture.file.content_type
      self.size = picture.file.size
    end
  end

end
