module Campanify
  module Controllers
  module ReferralsController
    extend ActiveSupport::Concern
    
    included do
      before_filter :catch_referrer
      helpers = %w(referrer referrer=)
      helper_method *helpers
      hide_action   *helpers
    end
    
    
    def referrer
      User.find(session[:referrer]) if session[:referrer]
    end
  
    def referrer=(referrer)
      session[:referrer] = referrer
    end

    
    private
    
    def catch_referrer
      self.referrer = params[:referrer] if params[:referrer]
    end
  end  
  end
end