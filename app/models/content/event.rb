class Content::Event < ActiveRecord::Base
  attr_accessible :description, :end_time, :fb_id, :location, :name, :parent, :privacy, :start_time, :venue
end
