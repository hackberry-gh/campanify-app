class Administrator < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :full_name, :phone, :role, :meta
  
  ROLES = %w(root developer editor)
  
  serialize :meta, Hash
  
  before_validation { |admin|
    if admin.new_record?
      admin.password = admin.password_confirmation = Devise.friendly_token.first(6)
    end
  }
  
  after_create { |admin| admin.send_reset_password_instructions }
  
  validates_presence_of :full_name, :role
  
end
