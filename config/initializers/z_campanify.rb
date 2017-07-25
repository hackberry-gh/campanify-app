# i18
require 'i18n/backend/active_record'

Translation = I18n::Backend::ActiveRecord::Translation

Translation.class_eval do
  %w(errors html sharing widgets).each do |scope_name|
  scope :"#{scope_name}", lookup("#{scope_name}")
  end
  scope :authentication, where("key LIKE '%devise%' AND key NOT LIKE '%devise.mail%'")
  scope :models, lookup("activerecord")
  scope :mails, where("key LIKE '%mail%' AND NOT LIKE '%activerecord%'")
  validates_presence_of :value
end

I18n::Backend::ActiveRecord::Missing.class_eval do
  
  def translate(locale, key, options = {})
    if valid_keys.include? key.to_s.split(".").first
      super
    else
      I18n.backend.backends[1].translate locale, key, options
    end  
  end
  
  def valid_keys
    @valid_keys ||= Translation.where(locale: "en").all.map{|t| t.key.split(".").first}.compact.uniq
  end
end

I18n::Backend::ActiveRecord.send(:include, I18n::Backend::ActiveRecord::Missing)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Cache)
I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
I18n::Backend::Simple.send(:include, I18n::Backend::Cache)

I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n::Backend::Simple.new) 

I18n.class_eval do
  def self.available_locales
    Settings.i18n['available_locales'].map(&:to_sym).sort
  end
  def self.completed_locales
    Settings.i18n['completed_locales'].map(&:to_sym).sort
  end
end

# mailing, assets, etc
Campanify::Application.configure do
  # when u r a gem below is working
  # ::ActionMailer::Base.default_url_options = { :host => Settings.mailer["host"] }          
  I18n.enforce_available_locales = false
  config.action_mailer.default_url_options = { :host => Settings.mailer["host"] }
  config.i18n.default_locale = Settings.i18n['default_locale']
  config.time_zone = Settings.timezone
  config.i18n.available_locales = I18n.available_locales
end

# devise
Devise.setup do |config|
  config.mailer_sender = Settings.mailer["sender"]
  config.allow_unconfirmed_access_for = Settings.user['confirmation_required'] == "strict" ? 0 : Settings.devise_settings['allow_unconfirmed_access_for'].days
  config.reset_password_within = Settings.devise_settings['reset_password_within'].days
  config.invitation_limit = Settings.devise_settings["invitation_limit"]
  require "omniauth-facebook"
  config.omniauth :facebook, Settings.facebook['app_id'], Settings.facebook['app_secret'], 
                  {:scope => Settings.facebook['scope']}
  require "omniauth-twitter"
  config.omniauth :twitter, Settings.twitter['consumer_key'], Settings.twitter['consumer_secret']
end

# controllers
::Devise::PasswordsController.send :include, Campanify::Controllers::IpCountryBranchController     
::Devise::ConfirmationsController.send :include, Campanify::Controllers::IpCountryBranchController     
::Devise::UnlocksController.send :include, Campanify::Controllers::IpCountryBranchController 

::Devise::PasswordsController.send :include, Campanify::Controllers::TemplateController     
::Devise::ConfirmationsController.send :include, Campanify::Controllers::TemplateController     
::Devise::UnlocksController.send :include, Campanify::Controllers::TemplateController     

::ActionMailer::Base.send :include, Campanify::Controllers::TemplateController
::ActionMailer::Base.send :include, Campanify::Cache


# carier wave
require 'campanify/validators/file_size_validator'
require 'carrierwave/orm/activerecord'
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider                          => 'Google',                
    :google_storage_access_key_id      => ENV['GOOGLE_STORAGE_ACCESS_KEY_ID'], 
    :google_storage_secret_access_key  => ENV['GOOGLE_STORAGE_SECRET_ACCESS_KEY'],
  }
  config.fog_directory  = ENV['FOG_DIRECTORY']
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end

# Formstastic Globalize 3 Inputs
module Formtastic
  class FormBuilder
    def globalize_inputs(*args, &proc)
      index = options[:child_index] || "#{self.object.class.to_s.parameterize}-#{self.object.object_id}"
      linker = ActiveSupport::SafeBuffer.new
      fields = ActiveSupport::SafeBuffer.new
      Thread.current[:admin_locales].each do |locale|
        linker << self.template.content_tag(:li,
                  self.template.content_tag(:a, locale, :href => "#lang-#{locale}-#{index}" ),
                  :class => locale
        )
        fields << self.template.content_tag(:div,
        self.semantic_fields_for(*(args.dup << self.object.translation_for(locale)), &proc),
        :id => "lang-#{locale}-#{index}",
        :class => "language-fields"
        )
      end

      linker = self.template.content_tag(:ul, linker, :class => "language-selection clearfix")

      self.template.content_tag(:div, linker + fields, :class => "language-tabs-#{index}");
    end
  end
end

module ActiveAdmin
  class FormBuilder
    def globalize_inputs(*args, &proc)
      content = with_new_form_buffer { super }
      form_buffers.last << content.html_safe
    end
  end
end

module Campanify
  def self.geoip
    @@geoip ||= GeoIP.new("#{Rails.root}/db/GeoIP-106_20130402.dat")
  end
end

# Sendgrid
if Rails.env.production? || Rails.env.staging?
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
  }
  
  ActionMailer::Base.delivery_method = :smtp
end

# no fog uploads for development please
if Rails.env.development?
  Settings.reset!
  Settings.theme = "sta"
  Settings.media["storage"] = "file"
  Settings.assets["storage"] = "file"
  Settings.instance.save!
end

Twitter.configure do |config|
  config.consumer_key = Settings.twitter["consumer_key"]
  config.consumer_secret = Settings.twitter["consumer_secret"]
end
