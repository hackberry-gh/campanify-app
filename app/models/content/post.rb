class Content::Post < ActiveRecord::Base
  
  include Campanify::Models::Slug  
  include Campanify::Models::Publishable 
  include Campanify::Models::Sanitized
  include Campanify::Models::History
  include Campanify::Models::Popularity  
   
  attr_accessible :body, :published_at, :title, :user_id, :locale, :translations_attributes
  translates :title, :body, :fallbacks_for_empty_translations => true
  slug :title
  belongs_to :user
  accepts_nested_attributes_for :translations
  before_save :sanitize_inputs
  validates_presence_of :title, :body, :user_id

  track :likes
  
  has_and_belongs_to_many :likers, :class_name => "User", :join_table => "likers_posts", :association_foreign_key => "liker_id"
  
  scope :popularity, order('popularity DESC')
  scope :date, order('published_at DESC')
  
  def self.i18n_scope
  end
  
  def liked?(user)
    likers.include?(user)
  end
  
  alias_method :inc_likes_org, :inc_likes
  alias_method :dec_likes_org, :dec_likes  
  def inc_likes(owner = self)
    if owner.is_a?(User)
      likers << owner
      inc_likes_org(owner)
    end
  end
  
  def dec_likes(owner = self)
    if owner.is_a?(User)
      likers.delete(owner)
      dec_likes_org(owner)
    end
  end  
  
  private
  
  def sanitize_inputs 
    self.attributes.each do |k,v|
      self[k] = strip_tags(sanitize(v)) if v.is_a?(String)
    end
  end  
end
