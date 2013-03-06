class ContentSweeper < ActionController::Caching::Sweeper
  include Campanify::Cache
  
  observe Content::Event, Content::Page, Content::Post, Content::Widget
  
  # If our sweeper detects that a content was created call this
  def after_create(content)
    expire_cache_for(content)
  end

  # If our sweeper detects that a content was updated call this
  def after_update(content)
    expire_cache_for(content)
  end

  # If our sweeper detects that a content was deleted call this
  def after_destroy(content)
    expire_cache_for(content)
  end

  private
  def expire_cache_for(content)
    I18n.available_locales.each do |locale|
      
      expire_index(content, locale, 'none')
      expire_show(content, locale, 'none')      
      
      Settings.branches.keys.each do |branch|
        expire_index(content,locale, branch)
        expire_show(content, locale, branch)
      end
    end
  end
  def expire_index(content,locale,branch)
    @controller ||= ActionController::Base.new 
    total_pages = (content.class.cached_count.to_f / Settings.pagination["per"]).ceil
    (1..total_pages).each do |page|

      %w(none date popularity).each do |sort|
        cache_key = _cache_key(content.class.name, "index", page, sort, locale, branch)
        expire_action cache_key
        expire_fragment "#{cache_key}"
      end

    end
  end
  def expire_show(content,locale,branch)
    @controller ||= ActionController::Base.new 
    if content.respond_to?(:slug)
      cache_key = _cache_key(content.class.name, "show", content.slug, locale, branch)
      expire_action cache_key
      expire_fragment "#{cache_key}"
    else
      cache_key = _cache_key(content.class.name, "show", content.id, locale, branch)
      expire_action cache_key
      expire_fragment "#{cache_key}"
    end
  end
  
  # if ENV['PLAN'] != "free"
  #   handle_asynchronously :after_create
  #   handle_asynchronously :after_update
  #   handle_asynchronously :after_destroy
  # end
  
end