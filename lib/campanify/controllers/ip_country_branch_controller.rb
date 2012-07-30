module Campanify
  module Controllers
    module IpCountryBranchController
    
      extend ActiveSupport::Concern
    
      included do
        include Campanify::ThreadedAttributes
        threaded :ip
        threaded :country        
        threaded :branch
        helper_method :current_ip
        helper_method :current_country
        helper_method :current_branch
        prepend_before_filter :set_current_country_and_branch, :set_current_remote_ip
      end
    
      private
    
      def set_current_remote_ip
        self.class.current_ip = Rails.env.production? ? request.remote_ip : Settings.development['ip']
      end
    
      def set_current_country_and_branch
        self.class.current_country = GeoIP.new("#{Rails.root}/db/geo_ip.dat").country(current_ip).country_code2     
        self.class.current_branch = Settings.branches[current_country]
      end
    
    end
  end
end