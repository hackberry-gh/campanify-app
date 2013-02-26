class Content::Media < ActiveRecord::Base
  attr_accessible :description, :position, :title, :translations_attributes, :file, :user_id
  belongs_to :user
  translates :title, :description, :fallbacks_for_empty_translations => true
  mount_uploader :file, MediaUploader
  accepts_nested_attributes_for :translations
  validates_presence_of :title
  validates :file, :presence => true, :if => proc{|media| !media.external_link? }
  validates :file, 
  :integrity => true,
  :processing => true,
  # :presence => true, 
  :file_size => { 
    :maximum => 5.megabytes.to_i
  }

  scope :date, order('created_at DESC')
  scope :site, where(user_id: nil)
  scope :user, where("user_id > 0")

  def external_link?
    self.description && self.description.include?("http")
  end

  def link
    self.external_link? ? self.external_link : self.file.url
  end

  def external_link
    if is_youtube?
      description.gsub("http://www.youtube.com/watch?v=", "http://www.youtube.com/embed/") + "?rel=0"
    elsif is_vimeo?
      description.gsub("http://vimeo.com/", "http://player.vimeo.com/video/") + "?title=0&amp;byline=0&amp;portrait=0&amp;color=ffffff"
    else
      description
    end
  end

  def youtube_thumbnail
    description.gsub("http://www.youtube.com/watch?v=", "http://img.youtube.com/vi/") + "/1.jpg"
  end

  def vimeo_thumbnail
    hash = HTTParty.get "http://vimeo.com/api/v2/video/#{description.gsub("http://vimeo.com/","")}.json"
    hash[0]['thumbnail_medium']
  end

  %w(is_image? is_video? is_audio?).each do |m|
    class_eval <<-CODE
    def #{m}
      file.#{m}(file.file) if file.file.present?
    end  
    CODE
  end

  def is_youtube?
    external_link? && description.include?("youtube")
  end

  def is_vimeo?
    external_link? && description.include?("vimeo")
  end

end
