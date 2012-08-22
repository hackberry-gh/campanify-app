class Campaign < ActiveRecord::Base
  include Heroku::Managable
  
  attr_accessible :name, :slug
  
  manage_with :slug
  
  def slug
    "campanify-#{name.parameterize}"
  end
  
end
