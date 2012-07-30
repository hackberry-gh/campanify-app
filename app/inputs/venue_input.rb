class VenueInput < HashInput
  
  def hash_fields
    buffer = ""
    label = "#{method}".titleize
    buffer << "<li class=\"hash\"><label>#{label}</label><fieldset class=\"inputs\"><ul>"
    object[method.to_sym].each do |_key,_value|			
      name = "#{object_name}[#{method}][#{_key}]".to_sym
      buffer << builder.input("#{method}_#{_key}", 
      {:label => "#{_key}", :input_html => {:name => name, :value => _value}})
    end		
    buffer << "</ul>#{map}</fieldset></li>"
    buffer
  end
  
  def map
    "<div id=\"map_canvas\"></div>"
  end
  
end