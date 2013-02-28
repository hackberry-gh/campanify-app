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

  def formatted_user_field(f,field)
    case field 
    when :country
      f.country_code_select field
    when :email
      f.email_field field,  
      :"data-label" => t("activerecord.attributes.user.#{field}"),
      :placeholder => t("activerecord.attributes.user.#{field}")
    when :birth_year
      select_year nil, {
        :start_year => Date.today.year-120, 
        :end_year => Date.today.year, 
        :max_years_allowed => 200, 
        :field_name => field,
        :prompt => t("activerecord.attributes.user.#{field}")
      }
    when :birth_date
      raw("<label class=\"input\">" + 
      f.label(field) +
      f.date_select(field, {
        :start_year => Date.today.year-120, 
        :end_year => Date.today.year,
        :prompt => { 
          :day => t("html.registration_form.select_day"), 
          :month => t("html.registration_form.select_month"), 
          :year => t("html.registration_form.select_year")
        }
      }) + 
      "</label>")  
    when :gender
      f.select field, [
        [t("html.registration_form.female"),User::FEMALE],
        [t("html.registration_form.male"),User::MALE]
      ], :prompt => t("activerecord.attributes.user.#{field}") 
    when :avatar
      raw("<label for=\"#{field}\" class=\"input\">" + 
        t("activerecord.attributes.user.#{field}") + " " +
        f.file_field(field, 
        :"data-label" => t("activerecord.attributes.user.avatar"), 
        :placeholder => t("activerecord.attributes.user.avatar")) + 
      "</label>")
    else
      f.text_field field,
        :"data-label" => t("activerecord.attributes.user.#{field}"),
        :placeholder => t("activerecord.attributes.user.#{field}")
    end
  end

end
