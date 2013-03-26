module MobileDetector
  # These are various strings that can be found in mobile devices.  Please feel free
  # to add on to this list.
  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
  'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
  'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
  'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
  'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
  'mobile'
  
  # Forces the request format to be :mobile
    
    def force_mobile_format
      request.format = :mobile
      # session[:mobile_view] = true if session[:mobile_view].nil?
    end

    # Determines the request format based on whether the device is mobile or if
    # the user has opted to use either the 'Standard' view or 'Mobile' view.

    def set_mobile_format
      if is_mobile_device? && !request.xhr?
        request.format = session[:mobile_view] == false ? :html : :mobile
        session[:mobile_view] = true if session[:mobile_view].nil?
      end
    end

    # Returns either true or false depending on whether or not the format of the
    # request is either :mobile or not.

    def in_mobile_view?
      request.format.to_sym == :mobile
    end

    # Returns either true or false depending on whether or not the user agent of
    # the device making the request is matched to a device in our regex.

    def is_mobile_device?
      request.user_agent.to_s.downcase =~ Regexp.new(::MobileDetector::MOBILE_USER_AGENTS)
    end

    # Can check for a specific user agent
    # e.g., is_device?('iphone') or is_device?('mobileexplorer')

    def is_device?(type)
      request.user_agent.to_s.downcase.include?(type.to_s.downcase)
    end
  

end