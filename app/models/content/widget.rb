class Content::Widget < ActiveRecord::Base
  attr_accessible :body, :position, :title
end
