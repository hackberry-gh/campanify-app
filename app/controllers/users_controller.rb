class UsersController < CampanifyController
  
  include Campanify::Controllers::ParanoidController    
    
  before_filter  :safe_request!, :only => [:visits, :recruited]
  before_filter  :ensure_user!, :only => [:show, :visits, :recruited]
  
  helper_method :me?
  
  caches_action :index, 
                layout: false, 
                :cache_path => :index_cache_path.to_proc
  caches_action :show, 
                layout: false, 
                :cache_path => :show_cache_path.to_proc                
  cache_sweeper :user_sweeper              
  
  # GET, users index
  def index
    scope = User
    scope = scope.send(params[:sort] ||= "date")
    @users = scope.page(params[:page]).per(Settings.pagination["per"])    
  end

  # GET, show user page
  def show
  end

  # PUT, add a visit to user
  def visits
    @user.inc_visits unless me?
    render nothing: true
  end
	
	def index_cache_path
    _cache_key("user", "index", params[:page] || 1, params[:sort] || "none", I18n.locale, current_branch || "none")
  end
  
  def show_cache_path
    _cache_key("user", "show", params[:id], I18n.locale, current_branch || "none")    
  end
  
  private
	
  def ensure_user!
		redirect_to('/404') unless @user = User.find(params[:id])
	end
	
	def me?
	  current_user == @user
  end
  
end
