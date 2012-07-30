module Content
	class PagesController < ::ApplicationController
		
		# GET, renders page
	  def show
			@page = _cache Page, params[:id] do
	  		Page.published.find_by_slug(params[:id])
	  	end
	  	
	  	redirect_to '/404' and return if @page.nil? 
	  	render :layout => false if request.xhr?
	  end
	end
end