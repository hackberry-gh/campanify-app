module Campanify
  module Controllers  
    module ContentController
      extend ActiveSupport::Concern
      
      module ClassMethods
        def finder_method(method)
          class_variable_set :@@_finder_method, method
        end

        def scopes(*scopes)
          class_variable_set :@@_scoped, scopes
        end
      end
      
      included do
        class_variable_set :@@_scopes, nil
        class_variable_set :@@_finder_method, :find_by_id
        
        helper_method :content_class, :content_class_name, :scope
        
      end
      
      def index
    	  @resources = scope.page(params[:page]).per(Settings.pagination["per"])
  	  	render :layout => false if request.xhr?
  	  end

  	  def show
  	  	@resource = scope.send(finder_method, params[:id])
  	  	redirect_to '/404' and return if @resource.nil? 
  	  	render :layout => false if request.xhr?
  	  end
  	  
  	  private
      
      def finder_method
        self.class.class_variable_get :@@_finder_method
      end

      def scopes
        self.class.class_variable_get :@@_scopes
      end
      
      def content_class
  	    content_class_name.constantize
      end

  	  def content_class_name
  	    self.class.name.gsub('Controller','').singularize
      end  

      def scope
        scoped = content_class
        if scopes
          scopes.each { |scope| scoped = scoped.send(scope) if scoped.respond_to?(scope) }
        end
        scoped
      end  
      
    end  
  end
end