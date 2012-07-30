class User < ActiveRecord::Base
  
  include Campanify::Models::History
  include Campanify::ThreadedAttributes
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :full_name, :display_name, 
                  :birth_year, :birth_date, 
                  :country, :region, :city, :address, :post_code, :phone, :mobile_phone, 
                  :branch, :language, :send_updates, :legal_aggrement

  serialize :visits, Hash
  serialize :recruits, Hash
                    
  validate :validations_from_settings

  after_create :set_defaults

  before_validation { |user|
    if user.new_record? && setting("password_required") == "after_signup"
      user.password = user.password_confirmation = Devise.friendly_token.first(6)
    end
  }
  
  threaded  :branch
  track     :visits, :recruits
  
  def self.i18n_scope
    :user
  end

  def full_name
    "#{self.first_name} #{self.last_name}" unless self["full_name"]
  end

  def display_name
    self.full_name unless self["display_name"]
  end  

  def password_required?
    case setting("password_required")
    when "never"
      false
    when "always"  
      true
    when "after_signup"
      new_record? ? false : super
    when "auto"
      if confirmed?
        super
      else
        false
      end  
    else
      false  
    end
  end

  def setting(key)
    Settings.user_setting(key, self.branch)
  end

  def as_json_with_tokens
    as_json.merge(confirmation_token: confirmation_token, 
    authentication_token: authentication_token, 
    reset_password_token: reset_password_token).deep_symbolize_keys
  end

  def as_json(options = {})
    super(options.merge(except: [:visits, :recruits]))
  end

  private 

  def validations_from_settings
    setting("validates").each do |field|
      validates_presence_of field.to_sym
    end
  end

  def set_defaults
    self.reset_authentication_token!
    self.language = I18n.locale
    self.branch = current_branch
  end
                
end
