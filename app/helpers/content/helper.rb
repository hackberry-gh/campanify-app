module Content
  module Helper
    include ActionView::Template::Handlers

    def include_widget(slug)
      render_content Content::Widget.find_by_slug(slug)
    end

    def render_content(obj)
      (get_content(obj) || "").html_safe if obj
    end

    def render_widgets(parent)
      buffer = ""    
      if widgets = parent.widgets.ordered
        widgets.each do |widget|
          buffer << (get_content(widget) || "")
        end
      end
      buffer.html_safe
    end

    private

    def get_content(obj)
      unless obj.body.nil?
        body = parse_erb(obj.body)
        ERB.erb_implementation.new(body).result(binding)
      end
    end	

    def parse_erb(content)
      content.gsub("{%","<%").gsub("%}","%>")
    end
  end
end