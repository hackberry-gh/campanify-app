# encoding: utf-8
require 'carrierwave/processing/mime_types'

class AssetUploader < CarrierWave::Uploader::Base

  include CarrierWave::MimeTypes

  process :set_content_type

  # Choose what kind of storage to use for this uploader:
  storage Settings.assets["storage"].to_sym
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    dir = Settings.assets["storage"] == "file" ? "#{Rails.root}/public/" : ""
    "#{dir}assets/"
  end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(js css)
  end

  def move_to_cache
    false
  end
  
  def move_to_store
    true
  end

end
