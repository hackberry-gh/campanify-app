class User < ActiveRecord::Base
  
  include Campanify::Models::History
  include Campanify::ThreadedAttributes
  include Campanify::Models::Sanitized
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :full_name, :display_name, 
                  :birth_year, :birth_date, 
                  :country, :region, :city, :address, :post_code, :phone, :mobile_phone, 
                  :branch, :language, :send_updates, :legal_aggrement, 
                  :provider, :uid

  serialize :visits, Hash
  serialize :recruits, Hash
                    
  validate :validations_from_settings
  
  before_validation :set_defaults, :if => "new_record?"
  
  after_create :send_password_instructions

  # before_validation { |user|
  #     if user.new_record? && setting("password_required") == "never"
  #       user.password = user.password_confirmation = Devise.friendly_token.first(6)
  #     end
  #   }
  
  threaded  :branch
  track     :visits, :recruits
  
  def self.i18n_scope
  end
  
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    # user = User.where(:provider => auth.provider, :uid => auth.uid).first
    user = User.find_by_email(auth.info.email)
    unless user
      user = User.create(first_name: auth.extra.raw_info.first_name,
      last_name: auth.extra.raw_info.last_name,
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0,20]
      )
    end
    user
  end
  
  def setting(key)
    Settings.user_setting(key, self.branch)
  end
  
  def full_name
    "#{self.first_name} #{self.last_name}" unless self["full_name"]
  end

  def display_name
    self.full_name unless self["display_name"]
  end  

  def email_address
    self.email.present? ? self.email :  self.unconfirmed_email
  end
  
  def unconfirmed_email_address
    self.unconfirmed_email.present? ? self.unconfirmed_email :  self.email
  end  
  
  def password_required?
    puts "password_required? #{setting("password_required")}"
    case setting("password_required")
    when "never"
      false
    when "always"  
      true
    when "after_signup"
      new_record? ? false : super 
    when "after_signup_with_instructions"  
      new_record? ? false : super 
    else
      false  
    end
  end

  def confirmation_required?
    %w(never loose).include?( self.setting("confirmation_required") ) ? false : super
  end
  
  def reconfirmation_required?
    %w(never loose).include?( self.setting("confirmation_required") ) ? false : super
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
  
  # Before Validation if new record?
  def set_defaults
    self.branch = current_branch    
    self.language = I18n.locale    
    skip_reconfirmation!
    skip_confirmation! unless confirmation_required?
    self.reset_authentication_token    
    self.generate_reset_password_token if setting("password_required") == "after_signup"
  end
  
  # After Create
  def send_password_instructions
    self.send_reset_password_instructions if setting("password_required") == "after_signup_with_instructions" 
  end
             
end
