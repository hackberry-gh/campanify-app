class ApplicationController < ActionController::Base

  include Campanify::ActiveWidget
  include MobileDetector

  protect_from_forgery
  
  helper_method :querystring_params 

  def after_sign_up_path_for(resource)
    set_path_for_user('after_sign_up')
  end
  def after_sign_in_path_for(resource)
    set_path_for_user('after_sign_in')    
  end
  def after_sign_out_path_for(resource)
    set_path_for_user('after_sign_out')    
  end  
  def after_inactive_sign_in_path_for(resource)
    set_path_for_user('after_inactive_sign_in')    
  end  
  def after_accept_path_for(resource)
    # TODO: add path to settings after_accept_path
    set_path_for_user('after_sign_up')
  end

  def querystring_params
    params.except("controller","action","id","utf8","authenticity_token","user","commit","locale")
  end

  private

  def set_path_for_user(action)
    if current_user
      if current_user.setting('redirects')[action] == "show"
        user_path(current_user)
      else
        current_user.setting('redirects')[action]
      end
    else
      root_path
    end
  end

end
