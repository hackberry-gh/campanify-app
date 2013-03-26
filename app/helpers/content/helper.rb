module Content
  module Helper
    include ActionView::Template::Handlers

    def include_widget(slug)
      render_content Content::Widget.find_by_slug(slug), true
    end

    def render_content(obj, is_widget = false)
      (get_content(obj, is_widget) || "").html_safe if obj
    end

    private

    def get_content(obj, is_widget)
      unless obj.body.nil?
        # body = parse_erb(obj.body)
        body = is_widget ? obj.body.concat(add_widget_assets(obj)) : obj.body
        ERB.erb_implementation.new(body).result(binding)
      end
    end 

    # def parse_erb(content)
    #   content.gsub("{%","<%").gsub("%}","%>")
    # end

    def add_widget_assets(widget)
      assets = ""
      css = js = widget.slug
      assets << stylesheet_link_tag("widgets/#{css}", :media => "all") if !Dir.glob("#{Rails.root}/app/assets/stylesheets/widgets/#{css}.*").empty?
      assets << javascript_include_tag("widgets/#{js}") if !Dir.glob("#{Rails.root}/app/assets/javascripts/widgets/#{js}.*").empty?
      assets
    end

  end
end