ActiveAdmin.register Campaign do
  menu :parent => "Admin"  
  actions :index, :edit, :show
  # controller do
  #   def index
  #     redirect_to admin_campaign_path(Campaign.first.id)
  #   end
  # end
end
