class Campaign < ActiveRecord::Base
  include Heroku::Managable
  
  attr_accessible :name
  
  manage_with :slug
  
end
