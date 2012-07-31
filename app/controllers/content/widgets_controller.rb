module Content
  class WidgetsController < ApplicationController
    layout "embed"
    # GET, renders widget
    def show
      @widget = _cache Widget, params[:id] do
        Widget.find_by_id(params[:id])
      end
      redirect_to '/404' and return if @widget.nil? 
      render :layout => false if request.xhr?
    end
  end
end