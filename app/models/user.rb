class User < ActiveRecord::Base

  include Campanify::ThreadedAttributes
  include Campanify::Models::Sanitized

  if Settings.modules.include?("analytics")
    include Campanify::Models::History
    include Campanify::Models::Popularity
  end
  

  FEMALE = 1
  MALE = 2
    
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable, :omniauthable,
         :invitable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :full_name, :display_name, 
                  :birth_year, :birth_date, :gender, 
                  :country, :region, :city, :address, :post_code, :phone, :mobile_phone, 
                  :branch, :language, :send_updates, :legal_aggrement, 
                  :provider, :uid, :avatar, :remove_avatar, :remote_avatar_url,
                  :meta
  
  attr_accessor   :created_by_facebook_connect
                    
  # validate :validations_from_settings
  before_validation :validations_from_settings
  
  before_validation :set_defaults, :if => "new_record?"

  before_validation :parse_meta_attributes
  
  after_create :send_password_instructions

  after_invitation_accepted :invitation_accepted!
  
  has_many :posts, :class_name => "Content::Post", :dependent => :destroy
  has_many :media, :class_name => "Content::Media", :dependent => :destroy
  
  serialize :meta, Hash
  
  scope :popularity, order('popularity DESC')
  scope :date, order('created_at DESC')
  
  threaded  :branch

  if Settings.modules.include?("analytics")
    track     :visits, :recruits
  end
  
  mount_uploader :avatar, AvatarUploader
  validates :avatar, 
  :integrity => true,
  :processing => true,
  :file_size => { 
    :maximum => 2.megabytes.to_i
  }, 
  :if => "persisted?"
  
  def self.find_for_facebook_oauth(auth, current_user = nil)
    # user = User.where(:provider => auth.provider, :uid => auth.uid).first
    user = User.find_by_email(auth.info.email)
    unless user
      pass = Devise.friendly_token      
      user = User.create(first_name: auth.extra.raw_info.first_name,
      last_name: auth.extra.raw_info.last_name,
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: pass,
      password_confirmation: pass,
      remote_avatar_url: "http://graph.facebook.com/#{auth.uid}/picture?type=normal"
      )
      user.created_by_facebook_connect = true
    end
    user
  end
  
  def setting(key)
    Settings.user_setting(key, self.branch)
  end
  
  def timezone
    begin
      Settings.branches[user.branch]['timezone']
    rescue
      Settings.timezone
    end
  end
  
  def full_name
    self["full_name"] || (self.first_name || self.last_name ? "#{self.first_name} #{self.last_name}" : "User #{self.id}")
  end

  def display_name
    self["display_name"] || self.full_name|| "User #{self.id}"
  end  

  def email_address
    self.email.present? ? self.email :  self.unconfirmed_email
  end
  
  def unconfirmed_email_address
    self.unconfirmed_email.present? ? self.unconfirmed_email :  self.email
  end  
  
  def password_required?
    case setting("password_required")
    when "never"
      false
    when "always"  
      true unless (invited_by && new_record?)
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

  def accept_invitation!
    if self.invited_to_sign_up? && self.valid?
      self.invitation_accepted_at = Time.now.utc
      run_callbacks :invitation_accepted do
        self.invitation_token = nil
        self.confirmed_at = self.invitation_accepted_at if self.respond_to?(:confirmed_at) && !confirmation_required?
        self.save(:validate => false)
      end
    end
  end

  def as_json_with_tokens
    as_json.merge(confirmation_token: confirmation_token, 
    authentication_token: authentication_token, 
    reset_password_token: reset_password_token).deep_symbolize_keys
  end

  def as_json(options = {})
    super(options.merge(except: [:visits, :recruits]))
  end

  def method_missing(method, *args, &block)
    method = method.to_s
    if method.include?("meta_")
      key = method.gsub("meta_","")
      if key.include?("=")
        key = key.gsub("=","")
        value = self.meta[key] = args.shift
      else
        value = self.meta[key]
      end  
    else
      super(method.to_sym, *args, &block)
    end
    value
  end

  private 

  def validations_from_settings

    validates = Marshal::load(Marshal.dump(
      Settings.user_setting("validates", current_branch))
    )
    validates.recursive_symbolize_keys!
    # has_new_validations = false
    validates.each do |field, options|

      options.each do |kind, validate_options|

        validators = self.class.validators_on(field)

        if validators.empty? || !validators.map(&:kind).include?(kind)
          # has_new_validations = true
          
          # self.class.validates(field, options)
          if validate_options.is_a?(Hash)
            validate_options.to_validation_options!
            puts field, validate_options
            send :"validates_#{kind}_of", field, validate_options
          else  
            send :"validates_#{kind}_of", field
          end
        end

      end
    end

    # run_validations! if has_new_validations

  end
  
  # Before Validation if new record?
  def set_defaults
    self.branch = current_branch unless self.branch
    self.language = I18n.locale unless self.language    
    skip_reconfirmation!
    skip_confirmation! unless confirmation_required? || invited_to_signup_for_new_record?
    self.reset_authentication_token 
    self.generate_reset_password_token if setting("password_required") == "after_signup" && !invited_to_signup_for_new_record?
  end
  
  # After Create
  def send_password_instructions
    self.send_reset_password_instructions if setting("password_required") == "after_signup_with_instructions" && !invited_to_sign_up?
  end

  def invitation_accepted!
    invited_by.inc_recruits(self)
    send_password_instructions if setting("password_required") == "after_signup_with_instructions"
    send_confirmation_instructions if confirmation_required?
  end

  def invited_to_signup_for_new_record?
    (invited_by && new_record?)
  end

  def parse_meta_attributes
    meta_attributes.each do |attr|
      self.meta[attr.to_s.gsub("meta_","")] = self.send(attr)
    end
  end

  def mass_assignment_authorizer(role = :default)
    self.class.send :attr_accessor, *meta_attributes
    super(:default) + super(role) + meta_attributes
  end

  def meta_attributes
    @meta_attributes ||= Settings.user_setting("fields", current_branch).clone.delete_if{|s| !s.include?("meta_")}
  end
             
end
