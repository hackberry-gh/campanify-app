module Content
  module Helper
    include ActionView::Template::Handlers

    def render_content(obj)
      (get_content(obj) || "").html_safe if obj
    end

    def render_widgets(parent)
      buffer = ""    
      unless widgets = parent.widgets.ordered
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