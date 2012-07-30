class ArrayInput
  
  include Formtastic::Inputs::Base
  
  def to_html
    builder.input(method,{
      :as => @options[:format] || :string,
      :hint => @options[:hint],
      :input_html => {
        :value => object[method].join(",")
      }
    })
  end

  

end