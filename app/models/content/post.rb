class Content::Post < ActiveRecord::Base
  include Campanify::Models::Slug  
  include Campanify::Models::Publishable  
  attr_accessible :body, :published_at, :title, :user_id, :translations_attributes
  translates :title, :body, :fallbacks_for_empty_translations => true
  slug :title
  belongs_to :user
  accepts_nested_attributes_for :translations  
end
