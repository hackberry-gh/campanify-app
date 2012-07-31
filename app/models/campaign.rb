class Campaign < ActiveRecord::Base
  include Heroku::Managable
  
  attr_accessible :name, :slug
  
  attr_accessor :slug
  
  before_validation :set_slug
  
  manage_with :slug
  
  private
  
  def set_slug
    self.slug = "campanify-#{name.parameterize}"
  end
  
end
