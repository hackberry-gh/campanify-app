class ArrayInput
  
  include Formtastic::Inputs::Base
  
  def to_html
    value = object[method] || object.send(method.to_sym)
    builder.input(method,{
      :as => @options[:format] || :string,
      :hint => @options[:hint],
      :input_html => {
        :value => value.try(:join,",")
      }
    })
  end

end