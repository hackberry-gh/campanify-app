class Content::Widget < ActiveRecord::Base
  include Campanify::Models::Slug
  include Campanify::CounterCacher
  attr_accessible :body, :position, :title, :locale, :translations_attributes
  translates :title, :body, :fallbacks_for_empty_translations => true  
  slug :title
  scope :ordered,  order("position")
  accepts_nested_attributes_for :translations  
  validates_presence_of :title, :body  
end
