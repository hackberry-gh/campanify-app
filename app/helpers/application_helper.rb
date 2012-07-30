module ApplicationHelper
  def body_class
    "#{params[:controller].parameterize} #{params[:action]} #{params[:id]}"
  end
end