if Settings.has_table?
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
    config.assets.initialize_on_precompile = false    
  end

  # devise
  Devise.setup do |config|
    config.mailer_sender = Settings.mailer["sender"]
    config.allow_unconfirmed_access_for = Settings.devise_settings['allow_unconfirmed_access_for'].days
    config.reset_password_within = Settings.devise_settings['reset_password_within'].days
  end
  
  # controllers
  ::ActionMailer::Base.send :include, Campanify::Controllers::TemplateController
  # ::ActionMailer::Base.send :include, Campanify::Cache

  ApplicationController.send :include, Campanify::Controllers::TemplateController  
  ::ActionController::Base.send :include, Campanify::Controllers::IpCountryBranchController
  
  # ::Devise::RegistrationsController.send :include, Campanify::Controllers::ParanoidController
end