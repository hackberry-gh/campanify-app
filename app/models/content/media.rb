class Content::Media < ActiveRecord::Base
  attr_accessible :description, :position, :title
end
