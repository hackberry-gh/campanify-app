class Content::MediaController < ::CampanifyController
  
  before_filter :authenticate_user!, :only => [:new, :create]
  
  respond_to :html, :json
  
  include Campanify::Controllers::ContentController
  include Campanify::Controllers::ActionCacheController
  scopes :site, :date
  
  def create
    params[:content_media][:title] = "User Media #{current_user.id}"    
    @medium = current_user.media.create(params[:content_media])
    if @medium.persisted?
      redirect_to action: :new
    else
      @media = current_user.media
      render :new, layout: "embed"
    end
  end
  
  def new
    @media = current_user.media
    render layout: "embed"
  end

  private

  def content_class
    Content::Media
  end

  def content_class_name
    "Content::Media"
  end 
  
end