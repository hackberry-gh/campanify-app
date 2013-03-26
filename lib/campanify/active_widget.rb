module Campanify
	module ActiveWidget

		extend ActiveSupport::Concern

		included do
			include Campanify::ThreadedAttributes
			threaded :rendering_widgets
			helper_method :rendering_widgets if respond_to?(:helper_method)
			before_filter :garbage_old_renderings if respond_to?(:before_filter)
		end

		def rendering_widgets
			self.class.current_rendering_widgets || []
		end

	  private

	  def add_widgets_into_asset_render_list(resource)
	  	raise ArgumentError, "resource must be respond to body" unless resource.respond_to?(:body)
	  	self.class.current_rendering_widgets = [] unless current_rendering_widgets
	    resource.body.scan(/<%.*include_widget.*"(.*)".*%>/).flatten.each do |included_widget|
        self.class.current_rendering_widgets << included_widget
      end
	  end

	  def garbage_old_renderings
	  	self.class.current_rendering_widgets = []
	  end

	end
end