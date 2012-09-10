ActiveAdmin::ResourceController.class_eval do
  
  before_filter do
    I18n.locale = :en
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_dashboard_path, :alert => exception.message
  end

  protected

  def current_ability
    @current_ability ||= Ability.new(current_administrator)
  end
end