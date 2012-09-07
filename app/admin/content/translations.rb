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
      scope = params[:filter_by_locale] ? Translation.locale(params[:filter_by_locale]) : Translation
      @translations =  scope.page(1).per(scope.count)
    end
    def create
      if params[:translation][:locale].present?
        I18n.backend.store_translations(params[:translation][:locale],{params[:translation][:key] => params[:translation][:value]}, :escape => false)
      else
        I18n.available_locales.each do |locale|
          I18n.backend.store_translations(locale.to_s,{params[:translation][:key] => params[:translation][:value]}, :escape => false)
        end
      end
      redirect_to admin_translations_path
    end
    def update
      I18n.backend.store_translations(params[:translation][:locale],{params[:translation][:key] => params[:translation][:value]}, :escape => false)      
      redirect_to admin_translations_path      
    end
  end
  
  index do
    column :locale
    column :key    
    column :value        
    default_actions        
  end
  
  form do |f|
    f.inputs do
      f.input :locale, {:as => :select, :collection => I18n.available_locales, 
                        :hint => "leave blank to create in all languages"}.
                        merge!(f.object.new_record? ? {} : {:input_html => {:disabled => true}})
      f.input :key
      f.input :value, :as => :code, :mode => "html"
      # f.input :interpolations, :as => :array, :hint => "Comma seperated list"
      # f.input :is_proc, :as => :boolean, :default => false
    end
    f.buttons
  end
  
  sidebar :filters, :only => :index do
    div do
      h4 "Filter by Language"
      nav do
        span do 
          link_to "All", admin_translations_path,
          :class => "table_tools_button #{ params[:filter_by_locale].nil?  ? "active" : nil}"
        end
        I18n.available_locales.each do |l|
          span do
            link_to l.to_s.titleize, admin_translations_path(params.merge(:filter_by_locale => l)), 
            :class => "table_tools_button #{ params[:filter_by_locale] == l.to_s  ? "active" : nil}"
          end
        end
      end
    end
  end
end
