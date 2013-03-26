require "#{Rails.root}/lib/campanify/csv_importer"

module Jobs

  class CSVImporterJob < Struct.new(:filename, :klass, :uniq_field, :validate)
    def perform
      Campanify::CSVImporter.import filename, klass, uniq_field, validate
    end
    def error(job, exception)
      csv_import = CsvImport.find_or_create_by_filename(filename)
      csv_import.update_attribute(:results, exception.inspect)
    end
  end

  class ContentSweeperJob < Struct.new(:klass,:id,:on_update)

    include Campanify::Cache

    def perform
      expire_cache_for klass.constantize.find(id), on_update
    end

    private

    def expire_cache_for(content, on_update = false)

      I18n.available_locales.each do |locale|

        expire_index(content, locale, 'none')
        expire_show(content, locale, 'none') if on_update

        Settings.branches.keys.each do |branch|
          expire_index(content,locale, branch)
          expire_show(content, locale, branch) if on_update
        end
      end

      if content.is_a?(Content::Widget)
        Content::Page.where("body ILIKE '%#{content.slug}%'").each do |page|
          expire_cache_for(page, on_update)
        end
      end
    end

    def expire_index(content,locale,branch)
      total_pages = (content.class.cached_count.to_f / Settings.pagination["per"]).ceil
      (1..total_pages).each do |page|
        %w(none date popularity).each do |sort|
          cache_key = _cache_key(content.class.name, "index", page, sort, locale, branch)
          Rails.cache.delete("views/#{cache_key}")
        end

      end
    end

    def expire_show(content,locale,branch)
      cache_key = _cache_key(content.class.name, "show", content.try(:slug) || content.id, locale, branch)
      Rails.cache.delete("views/#{cache_key}")
    end
  end

  class UserSweeperJob < Struct.new(:klass, :id, :on_update)
    include Campanify::Cache
    def perform
      expire_cache_for(klass.constantize.find(id), on_update)
    end
    private
    def expire_cache_for(user, on_update = false)

      Rails.cache.delete("users_count")
      
      I18n.available_locales.each do |locale|

        expire_index(locale, 'none')
        expire_show(user, locale, 'none') if on_update

        Settings.branches.keys.each do |branch|
          expire_index(locale, branch)
          expire_show(user, locale, branch)  if on_update
        end
      end
    end
    def expire_index(locale,branch)
      # TODO: expire only changed user page
      total_pages = (User.cached_count.to_f / Settings.pagination["per"]).ceil
      (1..total_pages).each do |page|
        %w(none date popularity).each do |scope|
          cache_key = _cache_key("user", "index", page, scope, locale, branch)
          Rails.cache.delete("views/#{cache_key}")
        end
      end
    end
    def expire_show(user,locale,branch)
      cache_key = _cache_key("user", "show", user.id, locale, branch)
      Rails.cache.delete("views/#{cache_key}")
    end
  end

  class UserHooksJob < Struct.new(:hook, :id)

    include ActionView::Helpers::DateHelper

    def perform
      if user = User.find(id)
        do_hook(hook, user)
      end
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

    def send_to_pusher(event, user)
      begin
        resp = Pusher['registration_channel'].trigger!(event, {:user => {
                                                          :first_name => user.first_name,
                                                          # :flag => ActionController::Base.helpers.asset_path("flags/#{user.country.parameterize.underscore}.gif"),
                                                          :flag => "http://storage.googleapis.com/campanify-app-c-save-the-arctic/assets/flags/#{user.country.parameterize.underscore}.gif",
                                                          :country => I18n.t(user.country.to_sym, :scope => :countries),
                                                          :ago => distance_of_time_in_words_to_now(user.created_at)
        } })
        puts "--> Pusher resp #{resp}"
      rescue Pusher::Error => e
        puts "ERROR on UserObserver.send_to_pusher -> #{e.message}"
      end
    end

    def send_to_silverpop(url, user)

      body = {
        :EMAIL => user['email'],
        :first_name => user['first_name'],
        :last_name => user['last_name'],
        :id_num => user['meta'] ? user['meta']['national_id'] : "",
        :phone => user['phone'] || user['mobile_phone'],
        # :mobile_phone => user['mobile_phone'],
        :address => user['address'],
        :region => user['region'],
        :city => user['city'],
        :sms => user['meta'] ? user['meta']['sms'] : "",
        :country => user['country'],
        :dob => user['birth_date'],
        :yob => user['birth_year'],
        :src => (user['meta'] && user['meta']['request_params']) ? user['meta']['request_params']['src'] : "",
        :street => user['street'],
        :locale => user['language'],
        :postal_code => user['post_code'],
        :agree => user['legal_aggrement'],
        :updates => user['send_updates'],
        :bitly => ""
      }

      begin
        resp = HTTParty.post url, { body: body }
        puts "--> SILVERPOP RET: #{resp}"
      rescue Exception => e
        puts "ERROR on UserObserver.send_to_silverpop -> #{e.message}"
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
  end

end
