class Content::PagesController < ::CampanifyController
  include Campanify::Controllers::ContentController
  scopes :published
  finder_method :find_by_slug
  
  def show
  	@resource = scope.send(finder_method, params[:id])
  	redirect_to '/404' and return if @resource.nil? 
  	add_widgets_into_asset_render_list(@resource)
  	render :layout => false if request.xhr?
  end
  
  private 
  
  def add_widgets_into_asset_render_list(resource)
    resource.widgets.each{ |w| rendering_widgets << w.slug }
  	if included_widgets = resource.body.match(/<% include_widget ("*.*") %>/)
  	  for i in (0..(included_widgets.size-1))
  	    included_widget = included_widgets[i]
  	    rendering_widgets << included_widget.gsub('"',"") unless included_widget.include?("<%")
	    end
  	end
  end
  
end
