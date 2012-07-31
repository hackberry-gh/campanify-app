class Content::Post < ActiveRecord::Base
  include Campanify::Models::Slug  
  include Campanify::Models::Publishable 
  include Campanify::Models::Sanitized
   
  attr_accessible :body, :published_at, :title, :user_id, :locale, :translations_attributes
  translates :title, :body, :fallbacks_for_empty_translations => true
  slug :title
  belongs_to :user
  accepts_nested_attributes_for :translations
  before_save :sanitize_inputs
  validates_presence_of :title, :body, :user_id
  
  def self.i18n_scope
  end
  
  private
  
  def sanitize_inputs 
    self.attributes.each do |k,v|
      self[k] = strip_tags(sanitize(v)) if v.is_a?(String)
    end
  end  
end
