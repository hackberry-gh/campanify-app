class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Campanify::Controllers::IpCountryBranchController     
  include Campanify::Controllers::ReferralsController  
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      
      # add recruitment to the referrer
      if self.referrer && @user.created_by_facebook_connect
        self.referrer.inc_recruits(resource) 
        self.referrer = nil
        @user.created_by_facebook_connect = false
      end
      
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end