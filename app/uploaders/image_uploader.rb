# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process resize_and_pad: [1000, 1000]

  version :polaroid do
    process resize_and_pad: [500, 500]
  end

  version :thumbnail do
    process resize_and_pad: [72, 72]
  end

  version :icon, from_version: :thumbnail do
    process resize_and_pad: [36, 36]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
