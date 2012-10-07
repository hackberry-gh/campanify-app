module ApplicationHelper
  
  include Campanify::Cache
  include HtmlHelper

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end
  
  def resource_class
    User
  end  

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
  def has_sort(sort)
    params[:sort] == sort
  end
  
  def sharing_user
     user || current_user if users_enabled?
  end
  
  def social_sharing_url
    user_url(sharing_user) if sharing_user 
  end
  
  def social_sharing_title
     sharing_user ? t('sharing.user.title') : t('sharing.default.title')
  end
  
  def social_sharing_description
     sharing_user ? t('sharing.user.description') : t('sharing.default.description')
  end
  
  def social_sharing_tweet
     sharing_user ? t('sharing.user.tweet', url: user_url(sharing_user)) : t('sharing.default.tweet')
  end
  
  def social_sharing_image
     sharing_user ? user.avatar_url(:thumb) : image_path(t('sharing.default.image'))
  end
  
  def comments_available?(object)
    Settings.send(object)['comments'].present? && Settings.modules.include?(object.to_s)
  end

  def users_enabled?
    Settings.modules.include?("users")
  end
  
  def events_enabled?
    Settings.modules.include?("events")
  end
  
  def posts_enabled?
    Settings.modules.include?("posts")
  end
  
  def analytics_enabled?
    Settings.modules.include?("analytics")
  end
  
  def can_post?
    posts_enabled? && Settings.user_setting("abilities")['can_post'] && current_user.present?
  end  
  
  def can_comment?(object)
    comments_available?(object) && Settings.user_setting("abilities")['can_comment'] && current_user.present?
  end
  
end