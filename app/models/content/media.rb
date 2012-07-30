class Content::Media < ActiveRecord::Base
  require 'carrierwave/orm/activerecord'
  attr_accessible :description, :position, :title, :translations_attributes, :file
  translates :title, :description, :fallbacks_for_empty_translations => true
  mount_uploader :file, MediaUploader
  accepts_nested_attributes_for :translations
end
