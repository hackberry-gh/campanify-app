module Campanify
  module Controllers
    module ParanoidController
      extend ActiveSupport::Concern
      
      included do
        before_filter :safe_request!
      end
      
      private
      
      def safe_request!
    		render nothing: true, status: 403 if !request.get? && (request.remote_ip.nil? || !request.xhr?)
    	end
    	
    end
  end
end