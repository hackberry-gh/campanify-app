ActiveAdmin.register Settings, :as => "Settings" do
  menu :parent => "Admin"
  actions :index, :edit, :show, :update
  controller do
    def index
      redirect_to admin_setting_path(Settings.instance.id)
    end
    def show
      @settings = Settings.instance
    end
    def edit
      @settings = Settings.instance
    end
    def update
      Settings.instance.data = YAML::load(params[:settings][:data])
      if Settings.instance.save
        redirect_to admin_setting_path(Settings.instance.id),
        :notice => "Settings saved successfully"
      else
        redirect_to edit_admin_setting_path(Settings.instance.id),
        :notice => "Opps, we did something wrong, try again please"        
      end
    end
  end
  member_action :reset do
    Settings.reset!
    redirect_to admin_setting_path(Settings.instance.id)
  end
  action_item do
    link_to('Reset!', reset_admin_setting_path(Settings.instance.id))
  end
  show do
    pre do
       settings.data.to_yaml
    end
  end
  form do |f|
    f.inputs do
      f.input :data, :as => :settings
    end
    f.buttons
  end
end
