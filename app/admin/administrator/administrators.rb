include FacebookHelper

ActiveAdmin.register Administrator do
  
  controller.authorize_resource
  
  menu :parent => "Admin", :priority => 1, :if => proc{ can?(:read, Administrator) }  
  
  member_action :facebook_callback, :method => :get do
    # if params[:state] == current_administrator.id.to_s    

    @oauth = oauth(facebook_callback_admin_administrator_url(current_administrator))
    token = @oauth.get_access_token(params[:code])
    @graph = graph(token)

    begin
      facebook_user = @graph.get_object("me")
    rescue Exception => e
      redirect_to admin_administrator_path(current_administrator), :alert => e.message and return
    end

    if facebook_user["email"] == current_administrator.email
      accounts = @graph.get_connections("me", "accounts")
      # current_administrator.meta["facebook"] = facebook_user.to_hash.merge!({accounts: accounts.to_a.keep_if{|a| a["name"].include?(Campaign.first.name)}, access_token: token})
      current_administrator.meta["facebook"] = facebook_user.to_hash.merge!({accounts: accounts.to_a, access_token: token})        
      current_administrator.save!
      redirect_to admin_administrator_path(current_administrator), :notice => "Successfully linked with facebook user #{facebook_user["name"]}"
    else
      redirect_to admin_administrator_path(current_administrator), :alert => "Emails not mach"
    end
    # end
  end

  member_action :link_with_facebook, :method => :get do
    @oauth = oauth(facebook_callback_admin_administrator_url(current_administrator))
    redirect_to @oauth.url_for_oauth_code(:permissions => "email,manage_pages,user_events,create_event")
  end

  action_item :only => :edit do
    link_to('Link with facebook', link_with_facebook_admin_administrator_path(current_administrator))
  end
    
  show do |administrator|
    attributes_table do
      row :email
      row :full_name
      row :phone
      row :role
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip    
      row :meta do
        pre administrator.meta.to_yaml
      end
    end
  end
    
  index do
    selectable_column
    column :full_name
    column :email
    column :phone
    column :role
    default_actions
  end
  
  form do |f|
    f.inputs do
      f.input :email
      f.input :full_name
      f.input :phone
      f.input :role, :as => :select, :collection => Administrator::ROLES
    end
    f.buttons
  end
end
