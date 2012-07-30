module Campanify
  class Settings < ::ActiveRecord::Base

    include ActiveRecord::Singleton

    attr_accessible :data
    serialize       :data, Hash

    self.table_name = 'settings'
    
    class << self
                
      def has_table?
        ActiveRecord::Base.connection.tables.include?('settings')
      end

      def defaults
        @@defaults ||= YAML::load(File.read("#{Rails.root}/config/settings.yml"))[Rails.env]  	    
      end

      def instance
        @instance ||= first || create!(data: self.defaults)
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
  	
  end
end

Settings = Campanify::Settings