class Content::WidgetsController < ::CampanifyController
  
  include Campanify::Controllers::ContentController
  
  scopes 
  finder_method :find_by_id
    
  layout "embed"
  
  def show
  	@resource = scope.send(finder_method, params[:id])
  	redirect_to '/404' and return if @resource.nil? 
  	rendering_widgets << @resource.slug
  	render :layout => false if request.xhr?
  end
end
