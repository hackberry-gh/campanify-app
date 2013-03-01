class Hash
  def recursive_symbolize_keys!
    symbolize_keys!
    # symbolize each hash in .values
    values.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    # symbolize each hash inside an array in .values
    values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end
  def to_validation_options!
  	self.each{ |k,v|
  		if v.is_a?(Hash) 
  			v.to_validation_options! 
  		elsif v.is_a?(String)
  			s = v.scan(/\/(.*)\//).flatten
  			self[k] = Regexp.new(s.first) unless s.empty? 
  		end
  	}
  	values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.to_validation_options! if h.is_a?(Hash) }
  	self
  end
end