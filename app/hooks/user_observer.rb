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
    UserMailer.email(mail, user)
  end

  # posts user data to given url
  def http_post(url, user)
    begin
      HTTParty.post url, { body: user.attributes.as_json }
    rescue Exception => e
      puts "ERROR on UserObserver.http_post -> #{e.message}" 
    end
  end

  def tweet(message_id, user)
    begin
      tweet = tw_client(user).update(I18n.t(message_id)) if user.tw_token && user.tw_secret
    rescue Exception => e
      puts "ERROR on UserObserver.tweet -> #{e.message}" 
    end
  end

  # not implemented yet      
  def facebook(message_id, user)
    begin
      post = fb_client(user).put_connections("me", "feed", :message => I18n.t(message_id)) if user.fb_token
    rescue Exception => e
      puts "ERROR on UserObserver.tweet -> #{e.message}" 
    end
  end

  def tw_client(user = nil)
    @tw_client ||= TwitterOAuth::Client.new(
        :consumer_key => Settings.twitter["consumer_key"],
        :consumer_secret => Settings.twitter["consumer_secret"],
        :token => user.tw_token,
        :secret => user.tw_secret
    )
  end

  def fb_client(user = nil)
    @fb_client ||= Koala::Facebook::API.new(user.fb_token)
  end

  if ENV['PLAN'] != "free"
    handle_asynchronously :after_create
    handle_asynchronously :after_update
    handle_asynchronously :after_delete  
  end


end