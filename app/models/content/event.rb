class Content::Event < ActiveRecord::Base
  include Campanify::Models::Slug  
  include FacebookHelper
  attr_accessible :description, :end_time, :fb_id, :location, :name, :parent, 
                  :privacy, :start_time, :venue, :locale, :translations_attributes
  translates :name, :description, :fallbacks_for_empty_translations => true  
  slug :name
  serialize :venue, Hash
  after_initialize :set_venue
  validates_presence_of :name, :start_time
  
  validate :check_venue
  
  before_save :create_facebook_event
  before_destroy :destroy_facebook_event
  
  accepts_nested_attributes_for :translations
  
  scope :public, where(:privacy => "OPEN")
  
  private
  
  def set_venue
    self.venue = {street: "", city: "", state: "", zip: "", country: "", latitude: "", longitude: ""} if self.venue.empty?
  end
  
  def create_facebook_event
    if self.parent.present? && self.fb_id.nil?
      id, access_token = token_pair
      params = {
        name: name,
        start_time: start_time,
        end_time: end_time,
        description: description,
        location: location,
        privacy: privacy
      }
      
      params.merge!(self.venue.keep_if{|k,v| v.present? })
      
      @graph = graph(access_token)
      begin
        self.fb_id = @graph.put_object(id, "events", params)["id"]
      rescue Exception => e
        self.errors[:base] << e.message
      end
      
    end
  end
  
  def check_venue
    if venue.keys.keep_if{|k| !k.present? }.size > 0
      errors.add(:venue, :blank) 
    end
  end
  
  def destroy_facebook_event
    if token_pair.present?
      id, access_token = token_pair
      @graph = graph(access_token)
      @graph.delete_object(id)
    end
  end
  
  def token_pair
    @token_pair ||= self.parent.split("-") if self.parent
  end
end
