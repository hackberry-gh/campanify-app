module Campanify
  module Controllers
    module ReferralsController
      extend ActiveSupport::Concern

      included do
        include Campanify::ThreadedAttributes
        threaded :referer      
        before_filter :catch_referer      
      end

      private

      def catch_referer
        if request.method == "GET" && !request.xhr?
          if params[:referer] && referer = User.find_by_id(params[:referer])
            self.class.current_referer = referer
          elsif params[:controller] == "users" && params[:action] == "show" && !me? && !refered_from_our_site? && referer = User.find_by_id(params[:id])
            self.class.current_referer = referer
          end
        end
      end

      def refered_from_our_site?
        if uri = http_referer_uri
          uri.host == request.host
        end
      end
      
      def http_referer_uri
        request.referer && URI.parse(request.referer)
      end

    end
  end
end  