class UserObserver < ActiveRecord::Observer
  observe User
  def after_create(user)
    do_hook("after_create",user)
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
  def mail(method, user)
    UserMailer.send(method, user)
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

  if ENV['PLAN'] != "town"
    handle_asynchronously :mail
    handle_asynchronously :http_post
    handle_asynchronously :tweet
    handle_asynchronously :facebook
  end
end