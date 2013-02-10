class Content::MediaController < ::CampanifyController
  
  before_filter :authenticate_user!, :only => [:new, :create]
  
  respond_to :html, :json
    
  layout "embed"
  
  include Campanify::Controllers::ContentController
  include Campanify::Controllers::ActionCacheController
  scopes nil
  finder_method :find_by_id
  
  def create
    params[:content_media][:title] = "User Media #{current_user.id}"    
    @medium = current_user.media.create(params[:content_media])
    if @medium.persisted?
      redirect_to :action => :new
    else
      @media = current_user.media
      render :new
    end
  end
  
  def new
    @media = current_user.media
  end
  
  def show
  end
  
end