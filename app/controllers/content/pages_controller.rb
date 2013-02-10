class Content::PagesController < ::CampanifyController
  
  before_filter :set_resource_and_widgets, :only => :show
  
  include Campanify::Controllers::ContentController
  include Campanify::Controllers::ActionCacheController
  scopes :published
  finder_method :find_by_slug
  
  def show
  	redirect_to '/404' and return if @resource.nil? 
  	render :layout => false if request.xhr?
  end
  
  private 
  
  def set_resource_and_widgets
    @resource = scope.send(finder_method, params[:id])
    add_widgets_into_asset_render_list(@resource) if @resource
  end
  
  def add_widgets_into_asset_render_list(resource)
  	if included_widgets = resource.body.match(/<% include_widget ("*.*") %>/)
  	  for i in (0..(included_widgets.size-1))
  	    included_widget = included_widgets[i]
  	    rendering_widgets << included_widget.gsub('"',"") unless included_widget.include?("<%")
	    end
  	end
  end
  
end
