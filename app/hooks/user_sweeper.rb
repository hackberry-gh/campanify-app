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
    total_pages = (User.count.to_f / Settings.pagination["per"]).ceil
    (1..total_pages).each do |page|
      expire_action _cache_key("users", "index", page, locale, branch)
      expire_fragment _cache_key("users", "index", page, locale, branch)    
    end
  end
  def expire_show(user,locale,branch)
    expire_action _cache_key("users", "show", user.id, locale, branch)
    expire_fragment _cache_key("users", "show", user.id, locale, branch)
  end
  
  if ENV['PLAN'] != "free"
    handle_asynchronously :after_create
    handle_asynchronously :after_update
    handle_asynchronously :after_destroy  
  end
  
end