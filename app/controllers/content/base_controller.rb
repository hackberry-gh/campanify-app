module Content
	class BaseController < ::CampanifyController
	  # TODO fix  with class_variable_set
		@@_scopes = nil
		cattr_accessor :_scopes
    @@_finder_method = :find_by_id
		cattr_accessor :_finder_method
		    
		helper_method :content_class, :content_class_name, :scope
		
    caches_action :index, 
                  layout: false, 
                  :cache_path => :index_cache_path.to_proc
    caches_action :show, 
                  layout: false, 
                  :cache_path => :show_cache_path.to_proc                
    cache_sweeper :content_sweeper
		
		def self.finder_method(method)
      self._finder_method = method
    end
    
    def self.scopes(*scopes)
      self._scopes = scopes
    end
    
		def index
  	  @resources = scope.page(params[:page]).per(Settings.pagination["per"])
	  	render :layout => false if request.xhr?
	  end
		
	  def show
	    puts "#{params[:id]}"
	  	@resource = scope.send(finder_method, params[:id])
	  	redirect_to '/404' and return if @resource.nil? 
	  	render :layout => false if request.xhr?
	  end
	  
	  def content_class
	    content_class_name.constantize
    end
    
	  def content_class_name
	    self.class.name.gsub('Controller','').singularize
    end  
    
    def scope
      scoped = content_class
      if self.scopes
        scopes.each { |scope| scoped = scoped.send(scope) if scoped.respond_to?(scope) }
      end
      scoped
    end  

    def finder_method
      self.class._finder_method
    end
    
    def scopes
      self.class._scopes
    end

    def index_cache_path
      _cache_key(content_class_name, "index", params[:page], I18n.locale, current_branch || "none")
    end

    def show_cache_path
      _cache_key(content_class_name, "show", params[:id], I18n.locale, current_branch || "none")    
    end    
    
	end
end