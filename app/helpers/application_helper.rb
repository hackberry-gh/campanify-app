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
    user || current_user
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
  
end