# encoding: utf-8
require 'carrierwave/processing/mime_types'

class MediaUploader < CarrierWave::Uploader::Base

  include CarrierWave::MimeTypes
  
  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  # include Sprockets::Helpers::RailsHelper
  # include Sprockets::Helpers::IsolatedHelper

  # Choose what kind of storage to use for this uploader:
  storage Settings.media["storage"].to_sym
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    dir = Settings.media["storage"] == "file" ? "#{Rails.root}/public/" : ""
    "#{dir}uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end
  process :set_content_type

  # Create different versions of your uploaded files:
  Settings.media["versions"].each do |thumb|
    version thumb["name"].to_sym, :if => :is_image? do
      process thumb["process"].to_sym => thumb["sizes"]
    end
  end
  
  def is_image?(file)
    %w(jpg jpeg gif png).include?(file.path.split(".").last)
  end

  def is_video?(file)
    %w(flv mov).include?(file.path.split(".").last)
  end

  def is_audio?(file)
    %w(mp3 aiff).include?(file.path.split(".").last)
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png flv mov mp3 aiff pdf)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
