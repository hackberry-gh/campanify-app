# i18
require 'i18n/backend/active_record'

Translation = I18n::Backend::ActiveRecord::Translation

I18n::Backend::ActiveRecord::Missing.class_eval do
  def translate(locale, key, options = {})
    super
  rescue I18n::MissingTranslationData => e
    unless options[:count] and !I18n.t('i18n.plural.keys', :locale => locale).is_a?(Array)
      self.store_default_translations(locale, key, options)
    end
    raise e
  end
end

I18n::Backend::ActiveRecord::Implementation.class_eval do
  protected
  def lookup(locale, key, scope = [], options = {})
    key = normalize_flat_keys(locale, key, scope, options[:separator])
    result = Translation.locale(locale).lookup(key).all

    if result.empty?
      nil
    elsif result.first.key == key
      result.first.value
    else
      # chop_range = (key.size + FLATTEN_SEPARATOR.size)..-1
      # result = result.inject({}) do |hash, r|
      #   hash[r.key.slice(chop_range)] = r.value
      #   hash
      # end
      # result.deep_symbolize_keys
      chop_range = (key.size + ".".size)..-1                                
      result = result.inject({}) do |hash, r|
        choped_key = r.key.slice(chop_range)
        unless choped_key.include?(".")
          hash[choped_key] = r.value
        else
          sub_keys = choped_key.split(".")
          sub_key = sub_keys.first
          hash[sub_key] = lookup(locale, sub_key, key, options)
        end
        hash
      end
      result.deep_symbolize_keys      
    end

  rescue ::ActiveRecord::StatementInvalid
    # is the translations table missing?
    nil
  end
end

I18n::Backend::ActiveRecord.send(:include, I18n::Backend::ActiveRecord::Missing)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Flatten)
I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Pluralization)
I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Cache)
I18n.cache_store = ActiveSupport::Cache.lookup_store(:memory_store)

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n::Backend::Simple.new)

I18n.class_eval do
  def self.available_locales
    Settings.i18n['available_locales'].map(&:to_sym)
  end
  def self.completed_locales
    Settings.i18n['completed_locales'].map(&:to_sym)
  end
end

# mailing, assets, etc
Campanify::Application.configure do
  # when u r a gem below is working
  # ::ActionMailer::Base.default_url_options = { :host => Settings.mailer["host"] }          
  config.action_mailer.default_url_options = { :host => Settings.mailer["host"] }
  config.i18n.default_locale = Settings.i18n['default_locale']
  config.time_zone = Settings.timezone
end

# devise
Devise.setup do |config|
  config.mailer_sender = Settings.mailer["sender"]
  config.allow_unconfirmed_access_for = Settings.user['confirmation_required'] == "strict" ? 0 : Settings.devise_settings['allow_unconfirmed_access_for'].days
  config.reset_password_within = Settings.devise_settings['reset_password_within'].days
  require "omniauth-facebook"
  config.omniauth :facebook, Settings.facebook['app_id'], Settings.facebook['app_secret'], 
                  {:scope => Settings.facebook['scope']}
end

# controllers
::Devise::PasswordsController.send :include, Campanify::Controllers::IpCountryBranchController     
::Devise::ConfirmationsController.send :include, Campanify::Controllers::IpCountryBranchController     
::Devise::UnlocksController.send :include, Campanify::Controllers::IpCountryBranchController     
::ActionMailer::Base.send :include, Campanify::Controllers::TemplateController
::ActionMailer::Base.send :include, Campanify::Cache


# carier wave
require 'campanify/validators/file_size_validator'
require 'carrierwave/orm/activerecord'
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',                   # required
    :aws_access_key_id      => ENV['AWS_S3_KEY'],       # required
    :aws_secret_access_key  => ENV['AWS_S3_SECRET'],    # required
    # :region                 => 'eu-west-1'  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['AWS_S3_BUCKET']                    # required
  # config.fog_host       = 'https://assets.example.com'          # optional, defaults to nil
  # config.fog_public     = false                                 # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end

# Formstastic Globalize 3 Inputs
module Formtastic
  class FormBuilder
    def globalize_inputs(*args, &proc)
      index = options[:child_index] || "#{self.object.class.to_s.parameterize}-#{self.object.object_id}"
      linker = ActiveSupport::SafeBuffer.new
      fields = ActiveSupport::SafeBuffer.new
      ::I18n.available_locales.each do |locale|
        linker << self.template.content_tag(:li,
                  self.template.content_tag(:a, locale, :href => "#lang-#{locale}-#{index}" )
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

# Sendgrid
if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com'
  }
  ActionMailer::Base.delivery_method = :smtp
end