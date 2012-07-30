class HashInput
  
  include Formtastic::Inputs::Base
  
  def to_html
    input_wrapping do
      hash_fields.html_safe
    end
  end

  def hash_fields
    buffer = ""
    label = "#{method}".titleize
    buffer << "<li class=\"hash\"><label>#{label}</label><fieldset class=\"inputs\"><ul>"
    object[method.to_sym].each do |_key,_value|			
      name = "#{object_name}[#{method}][#{_key}]".to_sym
      buffer << builder.input("#{method}_#{_key}", 
      {:label => "#{_key}", :input_html => {:name => name, :value => _value}})
    end		
    buffer << "</ul></fieldset></li>"
    buffer
  end

end