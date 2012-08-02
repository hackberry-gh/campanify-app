class Content::PostsController < Content::BaseController
  scopes :published
  finder_method :find_by_slug
  
  include Campanify::Controllers::ParanoidController    
  respond_to :html, :json
  
  def create
    @resource = Content::Post.create(params[:content_post])
    if @resource.persisted?
      respond_with @resource, :location => post_url(@resource), :format => :json
    else
      respond_with @resource, :location => posts_url, :status => 422, :format => :json
    end
  end
end
