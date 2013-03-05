ActiveAdmin.register Translation, :as => "Translation" do
  controller.authorize_resource :class => Translation 
  menu :parent => "Content", :priority => 6, :if => proc{ can?(:read, Translation) }
  actions :index, :new, :create, :edit, :update, :destroy
  # config.clear_sidebar_sections!

  %w(authentication errors html sharing widgets models mails).each do |scope_name|
  scope :"#{scope_name}"
  end

  config.per_page = 100
  
  controller do
    # before_filter :set_interpolations, :only => [:create, :update]
    # skip_before_filter :skip_sidebar!
    # def set_interpolations
    #   params[:translation][:interpolations] = params[:translation][:interpolations].split(",").map(&:parameterize)
    # end
    # def index
    #   # scope = params[:filter_by_locale] ? Translation.locale(params[:filter_by_locale]) : Translation
    #   # @translations =  scope.page(1).per(scope.count)
    #   active_admin_collection = params[:filter_by_locale] ? active_admin_collection.locale(params[:filter_by_locale]) : active_admin_collection
    # end
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
  
  collection_action :clone, :method => :get do
      if params[:from] != params[:to]
        Translation.where(locale: params[:from]).each do |translation|
            I18n.backend.store_translations(params[:to],{translation.key => translation.value}, :escape => false)
        end
        redirect_to admin_translations_path, :notice => "Translations clonned"        
      else
        redirect_to admin_translations_path, :alert => "Translations has not been clonned"          
      end


  end
  
  index do
    selectable_column
    column :locale
    column :key    
    column :value        
    default_actions        
  end
  
  form do |f|
    f.inputs do
      f.input :locale, {:as => :select, :collection => I18n.available_locales, 
                        :hint => "leave blank to create in all languages"}.
                        merge!(f.object.new_record? ? {} : {:input_html => {:readonly => true}})
      f.input :key
      f.input :value, :as => :code, :mode => "html"
      # f.input :interpolations, :as => :array, :hint => "Comma seperated list"
      # f.input :is_proc, :as => :boolean, :default => false
    end
    f.buttons
  end
  
  # sidebar :filters, :only => :index do
  #   div do
  #     h4 "Filter by Language"
  #     nav do
  #       span do 
  #         link_to "All", admin_translations_path,
  #         :class => "table_tools_button #{ params[:filter_by_locale].nil?  ? "active" : nil}"
  #       end
  #       I18n.available_locales.each do |l|
  #         span do
  #           link_to l.to_s.titleize, admin_translations_path(params.merge(:filter_by_locale => l)), 
  #           :class => "table_tools_button #{ params[:filter_by_locale] == l.to_s  ? "active" : nil}"
  #         end
  #       end
  #     end
  #   end
  # end
  
  sidebar "Cloning", :only => :index do
    div do
      render "cloning"
    end
  end
  
end
