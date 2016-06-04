# == Schema Information
#
# Table name: offers
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  description     :text
#  price           :decimal(8, 2)    default(0.0)
#  expiration_date :datetime
#  person_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  total_available :integer
#  available_count :integer
#  group_id        :integer
#

require 'texticle/searchable'

class Offer < ActiveRecord::Base
  include ActivityLogger
  include AnnouncementBase
  include HasPhotos

  extend Searchable(:name, :description)

  module Scopes
    def active
      where("available_count > ? AND expiration_date >= ?", 0, DateTime.now)
    end
  end

  extend Scopes

  before_create :set_available_count

  validates :expiration_date, :total_available, :presence => true

  def considered_active?
    available_count > 0 && expiration_date >= DateTime.now
  end

  def calculate_amount(count)
    return nil unless (count.blank? or count.is_a?(Fixnum))
    if count.blank?
      price
    else
      price * count if (count > 0 && count <= available_count)
    end
  end

  private
    def set_available_count
      self.available_count = self.total_available
    end

end
