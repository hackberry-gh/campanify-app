class Content::Page < ActiveRecord::Base
  include Campanify::Models::Slug
  include Campanify::Models::Publishable  
  include Campanify::CounterCacher  
  attr_accessible :body, :published_at, :title, :widget_ids, :locale, :translations_attributes
  translates :title, :body, :fallbacks_for_empty_translations => true
  slug :title

  accepts_nested_attributes_for :translations
  validates_presence_of :title, :body
end
