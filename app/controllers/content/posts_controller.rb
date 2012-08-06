class Content::PostsController < Content::BaseController
  scopes :published
  finder_method :find_by_slug
  
  include Campanify::Controllers::ParanoidController    
  respond_to :html, :json
  
  helper_method :author?
  
  def create
    @resource = Content::Post.create(params[:content_post])
    if @resource.persisted?
      respond_with @resource, :location => post_path(@resource), :format => :json
    else
      respond_with @resource, :location => posts_path, :status => 422, :format => :json
    end
  end
  
  def index
    scope = Content::Post.published
    scope = scope.send(params[:sort] ||= "date")
    @resources = scope.page(params[:page]).per(Settings.pagination["per"])
  	render :layout => false if request.xhr?
  end
  
  def like
  	@resource = Content::Post.published.find_by_id(params[:id])
  	if @resource.inc_likes(current_user)
      render :json => @resource, :location => post_path(@resource)
	  else
      render :json => @resource, :location => posts_path, :status => 422
    end
  end
  
  def unlike
  	@resource = Content::Post.published.find_by_id(params[:id])
  	if @resource.dec_likes(current_user)
      render :json => @resource, :location => post_path(@resource)
	  else
      render :json => @resource, :location => posts_path, :status => 422
    end	
  end
  
  def preview
    render layout: "preview"
  end
  
  private 
  
  def author?
	  current_user == @resource.user if @resource
  end
end
