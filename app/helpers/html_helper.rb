module HtmlHelper
  def body_class
    "#{params[:controller].parameterize} #{params[:action]} #{params[:id]} language-#{I18n.locale} country-#{current_country} branch-#{current_branch}"
  end
  def logo
    image_tag t('html.header.logo')
  end
  def language_dropdown
    select_tag "language", options_for_select(
    I18n.completed_locales.collect{|l| [I18n.with_locale(l){ t('language') },l]}, 
    I18n.locale), :class => "language" if I18n.completed_locales.size > 1
  end
  
  def stylesheet_theme_tag
    Appearance::Asset.css.map{ |css|
      stylesheet_link_tag css.url, :media => "all"
    }.join("\n").html_safe
  end
  
  def javascript_include_theme
    Appearance::Asset.js.map{ |js|
      javascript_include_tag js.url
    }.join("\n").html_safe
  end
  
  def stylesheet_widgets_tag
    rendering_widgets.uniq.map{ |css| 
      stylesheet_link_tag "widgets/#{css}", :media => "all" if File.exists?("#{Rails.root}/app/assets/stylesheets/widgets/#{css}.css")
    }.join("\n").html_safe
  end
  
  def javascript_include_widgets
    rendering_widgets.uniq.map{ |js| 
      javascript_include_tag "widgets/#{js}" if File.exists?("#{Rails.root}/app/assets/javascripts/widgets/#{js}.js")
    }.join("\n").html_safe
  end

end