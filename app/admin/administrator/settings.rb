ActiveAdmin.register Settings do
  menu :parent => "Admin"
  actions :index, :edit, :show, :update
  controller do
    def index
      redirect_to admin_setting_path(Settings.instance.id)
    end
    def update
      Settings.instance.data = YAML::load(params[:settings][:meta])
      if Settings.instance.save
        redirect_to admin_setting_path(Settings.instance.id),
        :notice => "Settings saved successfully"
      else
        redirect_to edit_admin_setting_path(Settings.instance.id),
        :notice => "Opps, we did something wrong, try again please"        
      end
    end
  end
  show do
    pre do
       settings.meta.to_yaml
    end
  end
  form do |f|
    f.inputs do
      f.input :data, :as => :settings
    end
    f.buttons
  end
end
