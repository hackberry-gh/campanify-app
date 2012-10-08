class Content::PagesController < ::CampanifyController
  include Campanify::Controllers::ContentController
  scopes :published
  finder_method :find_by_slug
  
  def show
  	@resource = scope.send(finder_method, params[:id])
  	redirect_to '/404' and return if @resource.nil? 
  	@resource.widgets.each{ |w| rendering_widgets << w.slug }
  	render :layout => false if request.xhr?
  end
end
