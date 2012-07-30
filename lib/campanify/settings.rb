module Campanify
  class Settings < ::ActiveRecord::Base
    
    include Singleton
  
    attr_accessible :data
    serialize       :data, Hash
  
  	@@defaults = YAML::load(File.read("#{Rails.root}/config/settings.yml"))[Rails.env]
  	cattr_reader :defaults

    self.table_name = 'settings'

  	class << self

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
  			instance.data = self.defaults
  			instance.save!
  		end

  		# dumps everything
  		def dump
  			self.instance.data
  		end

  		# make dot notation available for first level settings
  		def method_missing(method, *args, &block)
  			if method.to_s.include?("=")
  				key = method.to_s.gsub("=","")
  				instance.data[key] = args.shift
  				instance.save!
  				value = instance.data[key]
  			else 
  				super unless value = instance.data[method.to_s]
  			end
  			value
  		end
  	end  

  	def initialize(*args)
  		@settings ||= self.class.first
  		if !@settings.nil?
  			@attributes = @settings.attributes
  			@settings   = super(@attributes)
  		else
  			@settings = super(data: self.class.defaults)
  			self.save!
  		end
  		@settings
  	end
  end
end

Settings = Campanify::Settings