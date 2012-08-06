module Content
  def self.table_name_prefix
    'content_'
  end
  def self.markdown
    @@markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(
    :filter_html => true),
    {:autolink => true, :space_after_headers => true})
  end
end
