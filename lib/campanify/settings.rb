module Campanify
  class Settings < ::ActiveRecord::Base

    include ActiveRecord::Singleton

    attr_accessible :data
    serialize       :data, Hash

    self.table_name = 'settings'

    validate :yaml_format
    
    class << self
                
      def has_table?
        ActiveRecord::Base.connection.tables.include?('settings')
      end

      def defaults
        @@defaults ||= YAML::load(File.read("#{Rails.root}/config/settings.yml"))[Rails.env]  	    
      end

      def instance
        if self.has_table?
          @instance ||= first || create!(data: self.defaults)
        else
          @instance ||= OpenStruct.new(data: self.defaults)
        end
      end
      
      # gets branched or default user settings
      def user_setting(key, branch = nil)
        if branch = Settings.branches[branch]
          branch["user"][key]
        else
          Settings.user[key]
        end
      end

      # resets to default
      def reset!
        self.instance.data = self.defaults
        self.instance.save!
      end

      # dumps everything
      def dump
        self.instance.data
      end

      # make dot notation available for first level settings
      def method_missing(method, *args, &block)
        method = method.to_s
        if method.include?("=")
          key = method.gsub("=","")
          self.instance.data[key] = args.shift
          self.instance.save!
          value = self.instance.data[key]
        else
          super(method.to_sym, *args, &block) unless value = self.instance.data[method]
        end
        value
      end
    end

    private

    def yaml_format
      errors.add(:base, "Modules must be an array") unless self.data["modules"].is_a?(Array)
      errors.add(:base, "Mailer must be a hash") unless self.data["mailer"].is_a?(Hash)
      errors.add(:base, "User must be a hash") unless self.data["user"].is_a?(Hash)
      errors.add(:base, "User:Abilities must be a hash") unless self.data["user"]["abilities"].is_a?(Hash)
      errors.add(:base, "User:Fields must be an array") unless self.data["user"]["fields"].is_a?(Array)
      errors.add(:base, "User:Options must be a hash") unless self.data["user"]["options"].is_a?(Hash)
      errors.add(:base, "User:Validates must be a hash") unless self.data["user"]["validates"].is_a?(Hash)
      errors.add(:base, "User:PasswordRequied must be a string") unless self.data["user"]["password_required"].is_a?(String)
      errors.add(:base, "User:ConfirmationRequied must be a string") unless self.data["user"]["confirmation_required"].is_a?(String)
      errors.add(:base, "User:Redirects must be a hash") unless self.data["user"]["redirects"].is_a?(Hash)
      errors.add(:base, "User:Hooks must be a hash") unless self.data["user"]["hooks"].is_a?(Hash)
      errors.add(:base, "User:Hooks:AfterCreate must be an array") unless self.data["user"]["hooks"]["after_create"].is_a?(Array)
      errors.add(:base, "Timezone must be a string") unless self.data["timezone"].is_a?(String)
      errors.add(:base, "I18n must be a hash") unless self.data["i18n"].is_a?(Hash)
      errors.add(:base, "I18n:DefaultLocale must be a string") unless self.data["i18n"]["default_locale"].is_a?(String)
      errors.add(:base, "I18n:AvailableLocales must be an array") unless self.data["i18n"]["available_locales"].is_a?(Array)
      errors.add(:base, "I18n:CompletedLocales must be an array") unless self.data["i18n"]["completed_locales"].is_a?(Array)
      errors.add(:base, "I18n:PreferredSource must be an array") unless self.data["i18n"]["preferred_source"].is_a?(String)
      errors.add(:base, "Branches must be a hash") unless self.data["branches"].is_a?(Hash)
      errors.add(:base, "Assets must be a hash") unless self.data["assets"].is_a?(Hash)
      errors.add(:base, "Media must be a hash") unless self.data["media"].is_a?(Hash)
      errors.add(:base, "Devise Settings must be a hash") unless self.data["devise_settings"].is_a?(Hash)
      errors.add(:base, "Pages must be a hash") unless self.data["pages"].is_a?(Hash)
      errors.add(:base, "Posts must be a hash") unless self.data["posts"].is_a?(Hash)
      errors.add(:base, "Events must be a hash") unless self.data["events"].is_a?(Hash)
      errors.add(:base, "Users must be a hash") unless self.data["users"].is_a?(Hash)
      errors.add(:base, "Facebook must be a hash") unless self.data["facebook"].is_a?(Hash)
    end
  	
  end
end

Settings = Campanify::Settings