ActiveAdmin.register Translation, :as => "Translation" do
  menu :parent => "Content"
  actions :index, :new, :create, :edit, :update, :destroy
  config.clear_sidebar_sections!
  controller do
    # before_filter :set_interpolations, :only => [:create, :update]
    skip_before_filter :skip_sidebar!
    # def set_interpolations
    #   params[:translation][:interpolations] = params[:translation][:interpolations].split(",").map(&:parameterize)
    # end
    def index
      @translations = params[:filter_by_locale] ? Translation.locale(params[:filter_by_locale]).page(params[:page]) : Translation.page(params[:page])
    end
    def create
      I18n.backend.store_translations(params[:translation][:locale],{params[:translation][:key] => params[:translation][:value]})
      redirect_to admin_translations_path
    end
    def update
      I18n.backend.store_translations(params[:translation][:locale],{params[:translation][:key] => params[:translation][:value]})      
      redirect_to admin_translations_path      
    end
  end
  
  index do
    column :locale
    column :key
    default_actions        
  end
  
  form do |f|
    f.inputs do
      f.input :locale, :as => :select, :collection => I18n.available_locales
      f.input :key
      f.input :value, :as => :code, :mode => "text"
      # f.input :interpolations, :as => :array, :hint => "Comma seperated list"
      # f.input :is_proc, :as => :boolean, :default => false
    end
    f.buttons
  end
  
  sidebar :filters, :only => :index do
    div do
      h4 "Filter by Language"
      nav do
        I18n.available_locales.each do |l|
          span do
            link_to l.to_s, admin_translations_path(params.merge(:filter_by_locale => l)), 
            :class => "table_tools_button #{ params[:filter_by_locale] == l.to_s  ? "active" : nil}"
          end
        end
      end
    end
  end
end
