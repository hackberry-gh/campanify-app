class Content::WidgetsController < ::CampanifyController
    
  layout "embed"
  
  include Campanify::Controllers::ContentController
  include Campanify::Controllers::ActionCacheController
  
  def show
  	@resource = scope.send(finder_method, params[:id])
  	redirect_to '/404' and return if @resource.nil? 
  	rendering_widgets << @resource.slug
  	render :layout => false if request.xhr?
  end
end
