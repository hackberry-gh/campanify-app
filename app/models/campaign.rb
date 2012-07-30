class Campaign < ActiveRecord::Base
  include Heroku::Managable
  
  @slug = "campanify-#{name.parameterize}"
  attr_reader :slug
  
  manage_with :slug
  
end
