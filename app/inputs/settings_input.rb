class SettingsInput
  
  include Formtastic::Inputs::Base
  
  def to_html
    builder.input(method,{
      :as => :text,
      :hint => @options[:hint],
      :wrapper_html => {:style => "list-style:none"},
      :input_html => {
        :class => "code",
        :"data-mode" => "yaml",
        :value => object[method].to_yaml
      }
    })
  end

  

end