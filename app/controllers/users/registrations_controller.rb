class Users::RegistrationsController < Devise::RegistrationsController
  include Campanify::Controllers::TemplateController  
  include Campanify::Controllers::ReferralsController 
  include Campanify::Controllers::IpCountryBranchController     
  include Campanify::Controllers::ParanoidController    

  skip_before_filter :safe_request!, :only => [:update, :destroy]

  def create
    # signout current logged in user
    sign_out(:user)
    
    build_resource

    if resource.save

      # add recruitment to the referer
      current_referer.inc_recruits(resource) if current_referer
      self.class.current_referer = nil

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end

  end


  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if Settings.user_setting('password_required',current_branch) == "never" ? 
      resource.update_attributes(resource_params) : 
      resource.update_with_password(resource_params)
    
      resource.confirm! if !resource.confirmation_required? && !resource.confirmed?
      
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
        :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  protected

  def update_needs_confirmation?(resource, previous)
    resource.respond_to?(:pending_reconfirmation?) &&
    resource.pending_reconfirmation? &&
    previous != resource.unconfirmed_email
  end

end