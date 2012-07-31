class CodeInput < Formtastic::Inputs::TextInput
  
  def input_html_options
    {
      :class => "code",
      :"data-mode" => mode(object,method)
    }.merge(super)
  end

  def mode(object,method)
    asset_modes = {"application/javascript" => "javascript", "text/css" => "css"}
    if object.is_a?(Appearance::Asset)
      object.content_type ? asset_modes[object.content_type] : "text"
    else
      @options[:mode] || "text"
    end
  end
  
end