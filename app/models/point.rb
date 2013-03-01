class Point < ActiveRecord::Base
  attr_accessible :action, :amount, :user_id, :level_id, :source_id, :source_type
  
  belongs_to :user
  belongs_to :level

  validates_presence_of :user_id
  validates_presence_of :level_id
  validates_presence_of :amount
  validates_presence_of :action

  validates :amount, :numericality => {
  	:only_integer => true,
  	:less_than_or_equal => Settings.points["maximum_point_amount"],
  	:greater_than_or_equal => Settings.points["minimum_point_amount"]
  }

  validates :action, :inclusion => { :in => Settings.points["actions"].keys }
end
