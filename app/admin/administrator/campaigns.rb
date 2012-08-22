ActiveAdmin.register Campaign do
  menu :parent => "Admin"  

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
      row :price do
        "#{campaign.price / 100}$"
      end
      row :created_at
      row :updated_at      
    end
  end
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :domains, :as => :array, :hint => "Comma seperated"
      f.input :plan, :as => :select, :collection => Campanify::Plans.all, 
              :input_html => { :value => f.object.plan }, :include_blank => false
    end
    f.buttons
  end
  
  collection_action :restart do
    Campaign.first.restart!
    redirect_to :action => :show, :notice => "Server successfuly restarted!"
  end
  
  action_item do
    link_to "Restart!", restart_admin_campaigns_path
  end
  
end
