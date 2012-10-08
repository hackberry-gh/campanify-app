class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :rendering_widgets  
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
  
  def rendering_widgets
    @rendering_widgets ||= []
  end  
end
