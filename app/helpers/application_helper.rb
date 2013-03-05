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

  Settings.modules.each do |m|
    class_eval <<-CODE
    def #{m}_enabled?
      Settings.modules.include?("#{m}")
    end
    CODE
  end
  
  def can_post?
    posts_enabled? && Settings.user_setting("abilities")['can_post'] && current_user.present?
  end  
  
  def can_comment?(object)
    comments_available?(object) && Settings.user_setting("abilities")['can_comment'] && current_user.present?
  end

  def user_fields
    Settings.user_setting("fields", current_branch).map(&:to_sym)
  end

  def user_options
    Settings.user_setting("options",current_branch)
  end

  def password_always_required?
    Settings.user_setting("password_required",current_branch) == "always"
  end

  def password_required?
    Settings.user_setting('password_required', current_branch) != "never"
  end
  
end