class UserObserver < ActiveRecord::Observer
  observe User
  
  def after_create(user)
    do_hook("after_create",user)
    # locate user
  end

  def after_update(user)
    do_hook("after_update",user)
  end

  def after_delete(user)
    do_hook("after_delete",user)   
  end

  private

  def do_hook(hook,user)
    if hooks = user.setting("hooks")[hook]
      hooks.each do |name, action|
        self.send(name.to_sym, action, user)
      end
    end
  end

  # runs instance method on given user model
  def user(method, user)
    user.send(method)
  end

  # sends mail
  def mail(mail, user)
    puts "MAIL #{mail}, #{user}"
    email = UserMailer.email(mail, user)
    puts "email #{email}"
    email
  end

  # posts user data to given url
  def http_post(url, user)
    begin
      HTTParty.post url, { body: user.attributes.as_json }
    rescue Exception => e
      puts "ERROR on UserObserver.http_post -> #{e.message}" 
    end
  end

  # not implemented yet
  def tweet
    #TODO: implement tweet
  end

  # not implemented yet      
  def facebook
    #TODO: implement facebook
  end
  

  # def locate(user)
  #     begin
  #       url="http://maps.googleapis.com/maps/api/geocode/json?address=country:#{user.country.to_s}&sensor=false"
  #       response = HTTParty.get url
  #       if response["status"] = "OK"
  #         country_name = I18n.t(user.country.to_s, :scope => :countries)        
  #         location = nil
  #         response["results"].each do |loc|
  #           loc["address_components"].each do |add|
  #             location = loc["geometry"]["location"] if add["long_name"].include?(country_name)
  #           end
  #         end
  #         if location
  #           user.meta[:location] = location
  #           user.save(validate: false)
  #         end
  #       else
  #         user.meta[:location] = false                          
  #         user.save(validate: false)
  #       end
  #     rescue Exception => e
  #       user.meta[:location] = false
  #       user.save(validate: false)          
  #     end
  #   end

  if ENV['PLAN'] != "free"
    handle_asynchronously :after_create
    handle_asynchronously :after_update
    handle_asynchronously :after_delete  
  end
end