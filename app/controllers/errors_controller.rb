class ErrorsController < ApplicationController
  def routing
    redirect_to "/404"
    # render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end