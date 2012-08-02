class Content::Media < ActiveRecord::Base
  attr_accessible :description, :position, :title, :translations_attributes, :file
  translates :title, :description, :fallbacks_for_empty_translations => true
  mount_uploader :file, MediaUploader
  accepts_nested_attributes_for :translations
  validates_presence_of :title
  validates :file, 
  :integrity => true,
  :processing => true,
  :presence => true, 
  :file_size => { 
    :maximum => 5.megabytes.to_i
  }
end
