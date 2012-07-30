class Content::Page < ActiveRecord::Base
  include Campanify::Models::Slug
  include Campanify::Models::Publishable  
  attr_accessible :body, :published_at, :title, :translations_attributes
  translates :title, :body, :fallbacks_for_empty_translations => true
  slug :title
  has_and_belongs_to_many :widgets, :class_name => "Content::Widget"
  accepts_nested_attributes_for :translations
end
