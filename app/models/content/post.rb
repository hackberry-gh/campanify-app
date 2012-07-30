class Content::Post < ActiveRecord::Base
  attr_accessible :body, :published_at, :title, :user_id
end
