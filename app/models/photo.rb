# == Schema Information
# Schema version: 20090216032013
#
# Table name: photos
#
#  id           :integer(4)      not null, primary key
#  person_id    :integer(4)      
#  parent_id    :integer(4)      
#  content_type :string(255)     
#  filename     :string(255)     
#  thumbnail    :string(255)     
#  size         :integer(4)      
#  width        :integer(4)      
#  height       :integer(4)      
#  primary      :boolean(1)      
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Photo < ActiveRecord::Base
  include ActivityLogger
  UPLOAD_LIMIT = 5 # megabytes
  
  # attr_accessible is a nightmare with attachment_fu, so use
  # attr_protected instead.
  attr_protected :id, :person_id, :parent_id, :created_at, :updated_at
  
  belongs_to :person
  belongs_to :group
  belongs_to :photoable, :polymorphic => true

  has_attachment :content_type => :image, 
                 :storage => :s3,
                 :processor => 'Rmagick',
                 :max_size => UPLOAD_LIMIT.megabytes,
                 :min_size => 1,
                 :resize_to => '240>',
                 :thumbnails => { :thumbnail    => '72>',
                                  :icon         => '36>',
                                  :bounded_icon => '36x36>' }
  
  has_many :activities, :as => :item, :dependent => :destroy
  #validate :filename_to_upload_exists_and_images_are_correct_format

  before_save :update_photo_attributes
  after_save :log_activity

  class << self
    def migrate_to_carrierwave
      photos_to_be_migrated = self.where(parent_id: nil, picture: nil)
      num = photos_to_be_migrated.length
      puts "there are #{num} photos to be migrated to carrierwave..."
      photos_to_be_migrated.each do |photo|
        puts "...migrating photo #{photo.id}"
        photo.destroy_thumbnails
        photo.update_attributes!(remote_picture_url: photo.public_filename)
        photo.destroy_file
      end
      puts "All #{num} photos have been migrated to carrierwave!"
    end

    def polymorphisize
      self.all(conditions: 'person_id IS NOT NULL').each do |person_photo|
        person_photo.photoable_id = person_photo.person_id
        person_photo.photoable_type = 'Person'
        person_photo.save
      end

      self.all(conditions: 'group_id IS NOT NULL').each do |group_photo|
        group_photo.photoable_id = group_photo.group_id
        group_photo.photoable_type = 'Group'
        group_photo.save
      end
    end
  end

  mount_uploader :picture, ImageUploader

  # XXX temporary method while attachment-fu data is converted to carrierwave
  # 
  # after data is converted, this method and attachment-fu will be removed
  # and we'll call picture_url() instead of pic()
  def pic(pictype=nil)
    picture.blank? ? public_filename(pictype) : carrierwave_url(pictype).to_s
  end

  def carrierwave_url(pictype)
    pictype.nil? ? picture_url : picture_url(pictype)
  end

  # Override the crappy default AttachmentFu error messages.
  def filename_to_upload_exists_and_images_are_correct_format
    if filename.nil?
      errors.add(:base, "You must choose a file to upload")
    else
      # Images should only be GIF, JPEG, or PNG
      enum = attachment_options[:content_type]
      unless enum.nil? || enum.include?(send(:content_type))
        errors.add(:base, "You can only upload images (GIF, JPEG, or PNG)")
      end
      # Images should be less than UPLOAD_LIMIT MB.
      enum = attachment_options[:size]
      unless enum.nil? || enum.include?(send(:size))
        msg = "Images should be smaller than #{UPLOAD_LIMIT} MB"
        errors.add(:base, msg)
      end
    end
  end
  
  def log_activity
    if self.primary?
      unless self.person.nil?
        activity = Activity.create!(:item => self, :person => self.person)
        add_activities(:activity => activity, :person => self.person)
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
