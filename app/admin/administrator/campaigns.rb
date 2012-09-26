ActiveAdmin.register Campaign do
  
  controller.authorize_resource
  
  menu :parent => "Admin", :priority => 2, :if => proc{ can?(:read, Campaign) }

  actions :index, :edit, :show, :update

  controller do
    def index
      redirect_to admin_campaign_path(Campaign.first.id)
    end
    def update
      params[:campaign][:domains] = params[:campaign][:domains].split(",")
      @campaign = Campaign.first
      if @campaign.update_attributes(params[:campaign])
        redirect_to :action => :show, :notice => "Campaign successfuly updated"
      else
        render :edit  
      end
    end
  end
  
  show do |campaign|
    attributes_table do
      row :name
      row :domains do
        campaign.domains.join(",")
      end
      row :plan
      row :created_at
      row :updated_at      
    end
  end
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :domains, :as => :array, :hint => "Comma seperated"
    end
    f.buttons
  end
  
  collection_action :restart, :method => :put do
    Campaign.first.restart!
    redirect_to admin_campaigns_path, :notice => "Server successfuly restarted!"
  end
  
  action_item do
    link_to "Restart!", restart_admin_campaigns_path, :method => :put
  end
  
end
