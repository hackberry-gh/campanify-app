module Content::PagesHelper
  # include ActionView::Template::Handlers
	
	def page
	  @page
  end
	
	def render_page(page)
		render_viewable(page)
	end
	
	def render_widget(widget)
		render_viewable(widget)
	end
	
	def render_viewable(obj)
		(get_content(obj) || "").html_safe if obj
	end
	
	def render_widgets(parent)
		if parent
			buffer = ""    
			widgets = parent===Content::Page ? parent.widgets.sort_by{|w| w.position} : parent.sort_by{|w| w.position}
			unless widgets.nil?
				widgets.each do |widget|
	
					buffer << (get_widget_content(widget) || "")
	
				end
			end
			buffer.html_safe
		end
	end
	
	private
	
	def get_content(obj)
    # unless obj.body.nil?
    #   body = parse_erb(obj.body)
    #   ERB.erb_implementation.new(body).result(binding)
    # end
    obj.body
	end
	
	def get_widget_content(obj)
    # unless obj.body.nil?
    #   body = parse_erb(obj.body)
    #   template = <<-CONTENT
    #   <div class="well" id="#{obj.slug}">
    #   #{body}
    #   </div>
    #   CONTENT
    #   ERB.erb_implementation.new(template).result(binding)
    # end
    obj.body
	end
	
  # def parse_erb(content)
  #   content.gsub("{%","<%").gsub("%}","%>")
  # end
end
