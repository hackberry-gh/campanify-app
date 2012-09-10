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
      
      expire_index(content,locale, 'none')
      expire_show(content, locale, 'none')      
      
      Settings.branches.keys.each do |branch|
        expire_index(content,locale, branch)
        expire_show(content, locale, branch)
      end
    end
  end
  def expire_index(content,locale,branch)
    total_pages = (content.class.count.to_f / Settings.pagination["per"]).ceil
    (1..total_pages).each do |page|
      expire_action _cache_key(content.class.name, "index", page, locale, branch)
      expire_fragment _cache_key(content.class.name, "index", page, locale, branch)    
    end
  end
  def expire_show(content,locale,branch)
    expire_action _cache_key(content.class.name, "show", content.id, locale, branch)
    expire_fragment _cache_key(content.class.name, "show", content.id, locale, branch)
  end
  
  if ENV['PLAN'] != "town"
    handle_asynchronously :after_create
    handle_asynchronously :after_update
    handle_asynchronously :after_delete  
  end
  
end