class UsersController < ApplicationController
  
  before_filter  :safe_request!, :only => [:visits, :recruited]
  before_filter  :ensure_user!, :only => [:show, :visits, :recruited]
  
  helper_method :me?
  
  # GET, users index
  def index
    @users ||= User.page(params[:page]).per(Settings.pagination["per"])    
  end

  # GET, show user page
  def show
  end

  # PUT, add a visit to user
  def visits
    @user.inc_visits
    render nothing: true
  end
  
  # PUT, add a visit to user
  def recruited
    self.referrer.inc_recruits(@user) if self.referrer
    self.referrer = nil
    render nothing: true
  end  
	
  private
	
  def ensure_user!
		redirect_to('/404') unless @user = User.find(params[:id])
	end
	
	def me?
	  current_user == @user
  end
  
end
