# encoding: utf-8
require 'carrierwave/processing/mime_types'

class CsvUploader < CarrierWave::Uploader::Base

  include CarrierWave::MimeTypes

  process :set_content_type

  # Choose what kind of storage to use for this uploader:
  storage Settings.media["storage"].to_sym
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    dir = Settings.media["storage"] == "filesystem" ? "#{Rails.root}/public/" : ""
    "#{dir}uploads/csv/"
  end


  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(csv)
  end

  def filename
    "#{Time.now.to_i.to_s}_#{original_filename}" if original_filename
  end

end
