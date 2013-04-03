module Campanify
  module Controllers
    module IpCountryBranchController
    
      extend ActiveSupport::Concern
    
      included do
        include Campanify::ThreadedAttributes
        threaded :ip
        threaded :country        
        threaded :branch
        threaded :browser_language
        helpers = %w(current_ip current_country current_branch current_browser_language)
        helper_method *helpers
        hide_action *helpers       
        prepend_before_filter :set_language, :set_current_country_and_branch, :set_current_remote_ip
      end
    
      private
    
      def set_current_remote_ip
        self.class.current_ip = Rails.env.production? ? client_ip : Settings.development['ip']
      end
    
      def set_current_country_and_branch
        if params[:force_country]
          self.class.current_country= params[:force_country]
        else
          self.class.current_country = GeoIP.new("#{Rails.root}/db/geo_ip.dat").country(current_ip).country_code2     
        end
        self.class.current_branch = get_branch_from_country
      end
    
      def set_language
        # skip /admin
        unless request.fullpath.match(/^\/admin/)
          locale = override_by_url || self.send(Settings.i18n['preferred_source'].to_sym)
          # skip if not listed as completed
          I18n.locale = I18n.available_locales.include?(locale.to_sym) ? locale : I18n.default_locale
        end
      end
      
      private
      
      def client_ip
        return Settings.developemnt["ip"] if Rails.env.development?
        # request.headers["HTTP_X_REAL_IP"] || (request.headers["HTTP_X_FORWARDED_FOR"] ? request.headers["HTTP_X_FORWARDED_FOR"].split(",").first : nil) || request.remote_ip || request.ip
        request.headers["HTTP_X_REAL_IP"] || request.remote_ip || request.ip
      end
      
      def override_by_url
        params[:locale].try(:to_sym) || (request.env['omniauth.params'] ? request.env['omniauth.params']['locale'].try(:to_sym) : nil)
      end
      
      # extract_locale_from_accept_language_header      
      def from_browser
        unless request.env['HTTP_ACCEPT_LANGUAGE'].nil?
          self.current_browser_language = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first || request.env['HTTP_ACCEPT_LANGUAGE'].scan(/\w{2}-\w{2}/).first || I18n.default_locale
        end
      end
      
      # list should be manually entered in the settings
      def from_branch
        current_branch ? Settings.branches[current_branch]["locales"][0] : I18n.default_locale
      end

      def get_branch_from_country
        Settings.branches.each do |code,options|
          return code if options["country_code"].include?(current_country)
        end
        return nil
      end
    
    end
  end
end