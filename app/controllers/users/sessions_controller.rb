class Users::SessionsController < Devise::SessionsController
  def create

    if Settings.user_setting('password_required', current_branch) == "never"
      resource = User.find_by_email(params[:user][:email]) || warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      super
    end
  end

end