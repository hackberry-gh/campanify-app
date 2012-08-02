module HtmlHelper
  def body_class
    "#{params[:controller].parameterize} #{params[:action]} #{params[:id]} language-#{I18n.locale} country-#{current_country} branch-#{current_branch}"
  end
  def logo
    image_tag t('html.header.logo')
  end
  def language_dropdown
    select_tag "language", options_for_select(
    I18n.completed_locales.collect{|l| [I18n.with_locale(l){ t(l) },l]}, 
    I18n.locale) if I18n.completed_locales.size > 1
  end
end