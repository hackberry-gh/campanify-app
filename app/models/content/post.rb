class Content::Post < ActiveRecord::Base
  
  include Campanify::Models::Slug  
  include Campanify::Models::Publishable 
  include Campanify::Models::Sanitized
  
  if Settings.modules.include?("analytics")
    include Campanify::Models::History
    include Campanify::Models::Popularity  
  end
   
  attr_accessible :body, :published_at, :title, :user_id

  slug :title
  belongs_to :user

  before_save :sanitize_inputs
  validates_presence_of :title, :body, :user_id

  if Settings.modules.include?("analytics")
    track :likes
  
    has_and_belongs_to_many :likers, :class_name => "User", :join_table => "likers_posts", :association_foreign_key => "liker_id"
    
    if Settings.modules.include?("analytics")
      scope :popularity, order('popularity DESC')
    end

    scope :date, order('published_at DESC')
    
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

  end
  
  private
  
  def sanitize_inputs 
    self.attributes.each do |k,v|
      self[k] = sanitize(v, :tags => "iframe") if v.is_a?(String)
    end
  end  
end
