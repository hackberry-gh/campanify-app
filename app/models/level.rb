class Level < ActiveRecord::Base
  include Campanify::CounterCacher
  
  attr_accessible :meta, :sequence, :slug
  has_many :points, :dependent => :destroy
  has_many :users, :through => :points, :source => :user
  
  serialize :meta, Hash

  validates_presence_of :slug
  validates_uniqueness_of :slug

  validates_presence_of :sequence
  validates_uniqueness_of :sequence

  default_scope order(:sequence)

  attr_accessor :requirements

  after_initialize :ensure_requirements
  after_initialize :parse_meta
  before_save :parse_meta

  def requirements
  	meta["requirements"]
  end

  def requirements= value
  	meta["requirements"] = value
  end

  private

  def ensure_requirements
  	self.meta["requirements"] ||= {}
  end

  def parse_meta
    self.meta = YAML::load(self.meta) if self.meta.is_a?(String)
  end

end
