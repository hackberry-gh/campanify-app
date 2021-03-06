class Content::PostsController < ::CampanifyController

  before_filter :authenticate_user!, :only => [:create, :delete, :edit, :update]
  
  include Campanify::Controllers::ParanoidController    
  
  respond_to :html, :json
  
  helper_method :author?, :index_cache_path, :show_cache_path
  
  include Campanify::Controllers::ContentController  
  scopes :published
  finder_method :find_by_slug
  
  def create
    @resource = Content::Post.create(params[:content_post])
    if @resource.persisted?
      respond_with @resource, :location => post_path(@resource), :format => :json
    else
      respond_with @resource, :location => posts_path, :status => 422, :format => :json
    end
  end
  
  def update
    @resource = Content::Post.find(params[:id])

    if author? && @resource.update_attributes(params[:content_post])
      render :json => @resource, :location => post_path(@resource.slug)
    else
      render :json => @resource, :location => posts_path, :status => 422
    end
  end
  
  def destroy
    @resource = Content::Post.find(params[:id])
    @resource.destroy if author?
    render :json => {:redirect_to => posts_path}
  end
  
  if Settings.modules.include?("analytics")
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
  end
  
  def preview
    render layout: "preview"
  end

  # CACHE HELPERS
  def index_cache_path
    _cache_key(content_class_name, "index", params[:page] || 1, params[:sort] || "none", I18n.locale, current_branch || "none")
  end

  def show_cache_path
    _cache_key(content_class_name, "show", params[:id], I18n.locale, current_branch || "none")    
  end
  
  private 
  
  def author?
	  current_user == @resource.user if @resource
  end

  def scope
    scoped = content_class
    if scopes
      scopes.each { |scope| scoped = scoped.send(scope) if scoped.respond_to?(scope) }
    end
    scoped = scoped.send(params[:sort] ||= "date")
    scoped
  end 
end
