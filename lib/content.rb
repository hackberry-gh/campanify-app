module Content
  def self.table_name_prefix
    'content_'
  end
  def self.markdown
    @@markdown ||= Redcarpet::Markdown.new(
    Redcarpet::Render::VHTML.new({
    :filter_html => true, :hard_wrap => true}),
    {:autolink => false, :no_intra_emphasis => true})
  end
end
