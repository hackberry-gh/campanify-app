class UserSweeper < ActionController::Caching::Sweeper
  include Campanify::Cache
  
  observe User
  
  # If our sweeper detects that a user was created call this
  def after_create(user)
    expire_cache_for(user)
  end

  # If our sweeper detects that a user was updated call this
  def after_update(user)
    expire_cache_for(user)
  end

  # If our sweeper detects that a user was deleted call this
  def after_destroy(user)
    expire_cache_for(user)
  end

  private
  def expire_cache_for(user)
    I18n.available_locales.each do |locale|
      
      expire_index(locale, 'none')
      expire_show(user, locale, 'none')      
      
      Settings.branches.keys.each do |branch|
        expire_index(locale, branch)
        expire_show(user, locale, branch)
      end
    end
  end
  def expire_index(locale,branch)
    @controller ||= ActionController::Base.new 
    total_pages = (User.count.to_f / Settings.pagination["per"]).ceil
    (1..total_pages).each do |page|
      # cache_key = _cache_key("user", "index", page, locale, branch)
      cache_key = _cache_key("user", "index", page, "none", locale, branch)      
      expire_action cache_key      
      expire_fragment "views/#{cache_key}"      
      cache_key = _cache_key("user", "index", page, "popularity", locale, branch)            
      expire_action cache_key
      expire_fragment "views/#{cache_key}"
    end
  end
  def expire_show(user,locale,branch)
    @controller ||= ActionController::Base.new 
    cache_key = _cache_key("user", "show", user.id, locale, branch)
    expire_action cache_key 
    expire_fragment "views/#{cache_key}"
  end
  
  if ENV['PLAN'] != "free"
    handle_asynchronously :after_create
    handle_asynchronously :after_update
    handle_asynchronously :after_destroy  
  end
  
end