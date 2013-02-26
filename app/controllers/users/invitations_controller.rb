class Users::InvitationsController < Devise::InvitationsController
	include Campanify::Controllers::TemplateController  
  include Campanify::Controllers::IpCountryBranchController     
  include Campanify::Controllers::ParanoidController        

  before_filter :authenticate_inviter!, :only => [:new, :create, :send_to_contacts]
  before_filter :safe_request!, :only => [:send_to_contacts, :update]
  skip_before_filter :require_no_authentication, :only => [:edit]

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    sign_out(:user)

    if params[:invitation_token] && self.resource = resource_class.to_adapter.find_first( :invitation_token => params[:invitation_token] )
      render :edit
    else
      set_flash_message(:alert, :invitation_token_invalid)
      redirect_to after_sign_out_path_for(resource_name)
    end
  end

  # POST /resource/invitation
  def update
    self.resource = resource_class.accept_invitation!(resource_params)

    if resource.errors.empty?
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active                                                                                        
      set_flash_message :notice, flash_message
      sign_in(resource_name, resource)
      if request.xhr?
        render json: resource, location: after_accept_path_for(resource)
      else
        respond_with resource, :location => after_accept_path_for(resource)
     end
    else
      respond_with_navigational(resource){ render :edit }
    end
  end

	# POST invitations
  def send_to_contacts
    result = {}
    if params[:contacts].size <= 10
    	result[:invitations] = []
      params[:contacts].each do |email|
        result[:invitations] << User.invite!({email: email}, current_inviter)
      end
    else
      result[:error] = "you can invite maximum 10 people"
    end
    render json: result
  end

end