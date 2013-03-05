class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Campanify::Controllers::IpCountryBranchController     
  include Campanify::Controllers::ReferralsController  
  
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      
      # add recruitment to the referer
      if current_referer && @user.created_by_facebook_connect
        current_referer.inc_recruits(resource) 
        self.class.current_referer = nil
        @user.created_by_facebook_connect = false
      end
      
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def twitter
    
    @user = User.find_for_twitter_oauth(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      
      # add recruitment to the referer
      if current_referer && @user.created_by_twitter_connect
        current_referer.inc_recruits(resource) 
        self.class.current_referer = nil
        @user.created_by_twitter_connect = false
      end

      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end