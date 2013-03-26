class Content::WidgetsController < ::CampanifyController
    
  layout "embed"
  
  include Campanify::Controllers::ContentController
  
  
  finder_method :find_by_slug
  
  before_filter :prepare_widget

  include Campanify::Controllers::ActionCacheController

  def show
  	render :layout => false if request.xhr?
  end

  private

  def prepare_widget
    @resource = scope.send(finder_method, params[:id])
    redirect_to '/404' and return if @resource.nil? 
    rendering_widgets << @resource.slug
  end

  
end
